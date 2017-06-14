describe 'rake scheduled:clean:paper_trails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      Timecop.freeze
      expect(PaperTrail::Version).to receive(:destroy_all).with(["created_at < ?", 1.year.ago]).and_return([:a, :b, :c])
      expect(UserVersion).to receive(:destroy_all).with(["created_at < ?", 1.year.ago]).and_return([:a])
    end

    it 'Destroys relevant users' do
      expect { task.execute }.not_to raise_error
    end

    it 'Logs to stdout' do
      expect { task.execute }.to output([
        '3 old PaperTrail::Version deleted.',
        '1 old UserVersion deleted.',
        '4 total old versions deleted.',
      ].join("\n") + "\n").to_stdout
    end

  end # describe Executes

end
