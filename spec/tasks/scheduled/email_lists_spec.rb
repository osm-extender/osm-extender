describe 'rake scheduled:email_lists' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
    end

    it 'Checks all email lists'

    it 'No email lists to check'

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
