describe 'rake scheduled:clean:paper_trails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    Timecop.freeze
    expect(PaperTrail::Version).to receive(:destroy_all).with(["created_at < ?", 3.months.ago]).and_return([:a, :b, :c])
    expect(STDOUT).to receive(:puts).with('3 old versions deleted.')
    expect { task.execute }.not_to raise_error
  end

end
