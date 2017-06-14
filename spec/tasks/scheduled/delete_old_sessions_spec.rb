describe 'rake scheduled:delete_old_sessions' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      expect(Session).to receive(:delete_old_sessions).and_return([Session.new(id: 1), Session.new(id: 5), Session.new(id: 23)])
    end

    it 'Destroys relevant sessions' do
      expect { task.execute }.not_to raise_error
    end

    it 'Logs to stdout' do
      expect { task.execute }.to output("3 sessions deleted.\n").to_stdout
    end

  end # describe Executes

end
