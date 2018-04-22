describe 'rake scheduled:reminder_emails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      Timecop.freeze(DateTime.new(2017, 6, 11, 2, 0, 0)) # 2 AM on SUnday 11th June 2017
      @user = User.new(id: 2, name: 'user_name', email_address: 'name@example.com')
      @reminder = EmailReminder.new(
        id: 12,
        section_id: 3,
        section_name: 'section_name',
        user: @user
      )
    end

    it 'Sends email reminders for today' do
      reminders = [@reminder]
      reminders_where = double
      expect(EmailReminder).to receive(:where).with(:send_on => 0).and_return(reminders_where)
      expect(reminders_where).to receive(:order).with(:section_id).and_return(reminders)
      expect(STDOUT).to receive(:puts).with('Sending reminder emails')
      expect(STDOUT).to receive(:puts).with("\tSending 1 of 1 (id: 12)")
      expect(@reminder).to receive(:send_email)
      expect { task.execute }.not_to raise_error
    end

    it 'Handles no reminders for today' do
      reminders = []
      reminders_where = double
      expect(EmailReminder).to receive(:where).with(:send_on => 0).and_return(reminders_where)
      expect(reminders_where).to receive(:order).with(:section_id).and_return(reminders)
      expect(STDOUT).to receive(:puts).with('Sending reminder emails')
      expect(STDOUT).to receive(:puts).with("\tNo emails to send")
      expect { task.execute }.not_to raise_error
    end

    describe 'Handles exceptions' do

      before :each do
        reminders = [@reminder]
        reminders_where = double
        expect(EmailReminder).to receive(:where).with(:send_on => 0).and_return(reminders_where)
        expect(reminders_where).to receive(:order).with(:section_id).and_return(reminders)
        expect(STDOUT).to receive(:puts).with('Sending reminder emails')
        expect(STDOUT).to receive(:puts).with("\tSending 1 of 1 (id: 12)")
      end

      it 'Osm::Forbidden' do
        expect(@reminder).to receive(:send_email) { raise Osm::Forbidden }
        expect(STDOUT).to receive(:puts).with("\t\tUser is fobidden from fetching data")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['reminder-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Reminder Email for section_name FAILED'
        expect(mail.text_part.body.decoded).to include "Whilst trying to prepare your email reminder for section_name an\nerror occured - you can't access data in the section."
      end

      it 'Osm::Error::NoCurrentTerm' do
        expect(@reminder).to receive(:send_email) { raise Osm::Error::NoCurrentTerm }
        expect(STDOUT).to receive(:puts).with("\t\tNo current term for section")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['reminder-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Reminder Email for section_name FAILED'
        expect(mail.text_part.body.decoded).to include "Whilst trying to prepare your email reminder for section_name an\nerror occured - there is no current term."
      end

      it 'Exception from reminder.send_email' do
        exception = ArgumentError.new 'Just a test'
        expect(@reminder).to receive(:send_email) { raise exception }
        expect(STDOUT).to receive(:puts).with("\t\tAn Exception was raised (Just a test)")
        expect(Rollbar).to receive(:error).with(exception)
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['reminder-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Reminder Email for section_name FAILED'
        expect(mail.text_part.body.decoded).to include "Unfortunately your reminder email for section_name has failed"
      end

      it 'Exception from reminder.get_data' do
        exception = ArgumentError.new 'Just a test'
        expect(@reminder).to receive(:get_data) { raise exception }
        allow(@user).to receive(:connected_to_osm?).and_return(true)
        allow(@user).to receive(:osm_api).and_return(true)
        expect(Osm::Section).to receive(:get).and_return(true)
        expect(STDOUT).to receive(:puts).with("\t\tAn Exception was raised (Just a test)")
        expect(Rollbar).to receive(:error).with(exception)
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['reminder-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Reminder Email for section_name FAILED'
        expect(mail.text_part.body.decoded).to include "Unfortunately your reminder email for section_name has failed"
      end
    end # describe Handles exceptions

  end # describe Executes

end
