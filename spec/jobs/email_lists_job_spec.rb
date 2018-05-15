describe EmailListsJob do
  let(:subject) { described_class.new }

  describe 'Performs' do

    describe 'Checks an email list' do

      before :each do
        @list = EmailList.new(id: 123, name: 'list_name', user: User.new(name: 'user_name', email_address: 'name@example.com'))
        @lists = [@list]
        lists_where = double
        expect(EmailList).to receive(:where).with(:notify_changed => true).and_return(lists_where)
        expect(lists_where).to receive(:order).with(:section_id).and_return(@lists)
      end

      it 'No changes to addresses' do
        expect(@list).to receive(:get_hash_of_addresses).and_return('abcdefghijklmnopqrstuvwxyz')
        @list.last_hash_of_addresses = 'abcdefghijklmnopqrstuvwxyz'
        expect { subject.perform_now }.not_to raise_error
      end

      it 'Changes to addresses' do
        expect(@list).to receive(:get_hash_of_addresses).and_return('abcdefghijklmnopqrstuvwxyz')
        @list.last_hash_of_addresses = 'CHANGED'
        @list.user = User.new(name: 'user_name', email_address: 'name@example.com')
        expect(@list).to receive(:update_attributes).with(last_hash_of_addresses: 'abcdefghijklmnopqrstuvwxyz')
        expect{ subject.perform_now }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['notifications@osmx.example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Email List Changed'
        expect(mail.text_part.body.decoded).to match "user_name, at least one of the addresses in your\nlist_name email list for Unknown section changed."
      end

    end # describe checks an email list

    it 'No email lists to check' do
      lists = []
      lists_where = double
      expect(EmailList).to receive(:where).with(:notify_changed => true).and_return(lists_where)
      expect(lists_where).to receive(:order).with(:section_id).and_return(lists)
      expect { subject.perform_now }.not_to raise_error
    end

    describe 'Handles exceptions' do

      before :each do
        @list = EmailList.new(
          id: 123,
          name: 'list_name',
          user: User.new(id: 2, name: 'user_name', email_address: 'name@example.com'),
          section: Osm::Section.new(id: 3, name: 'section_name', group_name: 'section_group_name')
        )
        @lists = [@list]
        lists_where = double
        expect(EmailList).to receive(:where).with(:notify_changed => true).and_return(lists_where)
        expect(lists_where).to receive(:order).with(:section_id).and_return(@lists)
      end

      it 'Osm::Forbidden' do
        expect(@list).to receive(:get_hash_of_addresses) { raise Osm::Forbidden }
        expect{ subject.perform_now }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['notifications@osmx.example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Checking Email List For Changes FAILED'
        expect(mail.text_part.body.decoded).to match "Whilst trying to update the addresses in your email list\nlist_name an error occured - you can't access data in the\nsection."
      end

      it 'Osm::Error::NoCurrentTerm' do
        expect(@list).to receive(:get_hash_of_addresses) { raise Osm::Error::NoCurrentTerm }
        expect{ subject.perform_now }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['notifications@osmx.example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Checking Email List For Changes FAILED'
        expect(mail.text_part.body.decoded).to include "Whilst trying to update the addresses in your email list for\nsection_name (section_group_name) an error occured - there is no\ncurrent term."
      end

      it 'Exception' do
        exception = ArgumentError.new 'Just a test'
        expect(@list).to receive(:get_hash_of_addresses) { raise exception }
        expect(Rollbar).to receive(:error).with(exception)
        expect { subject.perform_now }.not_to raise_error
      end

    end # describe Handles exceptions

  end # describe Performs

end
