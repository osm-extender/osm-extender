describe 'rake scheduled:reminder_emails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      Timecop.freeze(DateTime.new(2017, 6, 11, 2, 0, 0)) # 2 AM on SUnday 11th June 2017
      @reminder = EmailReminder.new(
        id: 12,
        section_id: 3,
        section_name: 'section_name',
        user: User.new(id: 2, name: 'user_name', email_address: 'name@example.com')
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
        expect(mail.subject).to eq 'OSMExtender (TEST) - Preparing Email Reminder FAILED'
        expect(mail.text_part.body.decoded).to include "Whilst trying to prepare your email reminder for section_name an\nerror occured - you can't access data in the section."
      end

      it 'Osm::Error::NoCurrentTerm' do
        expect(@reminder).to receive(:send_email) { raise Osm::Error::NoCurrentTerm }
        expect(STDOUT).to receive(:puts).with("\t\tNo current term for section")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['reminder-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Preparing Email Reminder FAILED'
        expect(mail.text_part.body.decoded).to include "Whilst trying to prepare your email reminder for section_name an\nerror occured - there is no current term."
      end

      it 'Exception' do
        expect(@reminder).to receive(:send_email) { raise ArgumentError, 'Just a test' }
        expect(STDOUT).to receive(:puts).with("\t\tAn Exception was raised (Just a test)")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['exceptions@example.com']
        expect(mail.from).to eq ['notifier-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - An Exception Occured in a Rake Task'
        expect(mail.body.decoded).to include 'The message was: Just a test'
        expect(mail.body.decoded).to include 'The task was:    Reminder Email (id: 12, user: 2, section: 3)'
        expect(mail.body.decoded).to include 'The backtrace was:'
      end

    end # describe Handles exceptions

  end # describe Executes

end
