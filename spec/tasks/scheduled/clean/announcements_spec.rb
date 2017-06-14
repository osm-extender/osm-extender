describe 'rake scheduled:clean:announcements' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      expect(Announcement).to receive(:delete_old).and_return([:a])
    end

    it 'Destroys relevant users' do
      expect { task.execute }.not_to raise_error
    end

    it 'Logs to stdout' do
      expect { task.execute }.to output("1 announcements deleted.\n").to_stdout
    end

  end # describe Executes

end
