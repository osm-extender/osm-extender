describe 'rake scheduled:clean:paper_trails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    Timecop.freeze
    expect(PaperTrail::Version).to receive(:destroy_all).with(["created_at < ?", 3.months.ago]).and_return([:a, :b, :c])
    expect(UserVersion).to receive(:destroy_all).with(["created_at < ?", 3.months.ago]).and_return([:a])
    expect(STDOUT).to receive(:puts).with('3 old PaperTrail::Version deleted.')
    expect(STDOUT).to receive(:puts).with('1 old UserVersion deleted.')
    expect(STDOUT).to receive(:puts).with('4 total old versions deleted.')
    expect { task.execute }.not_to raise_error
  end

end
