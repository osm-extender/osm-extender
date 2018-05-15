describe 'rake scheduled:clean:paper_trails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to PrunePaperTrailsJob' do
    job = double(PrunePaperTrailsJob)
    expect(PrunePaperTrailsJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
