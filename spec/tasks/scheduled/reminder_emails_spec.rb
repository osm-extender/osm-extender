describe 'rake scheduled:reminder_emails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
    end

    it 'Sends email reminders for today'

    it 'Handles no emails for today'

    it 'Logs to stdout' do
      expect { task.execute }.to output([
        '',
      ].join("\n") + "\n").to_stdout
    end

    describe 'Handles exceptions' do

      it 'Osm::Forbidden'

      it 'Osm::Error::NoCurrentTerm'

      it 'Exception'

    end # describe Handles exceptions

  end # describe Executes

end
