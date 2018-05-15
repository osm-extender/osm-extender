describe 'rake scheduled:clean:balanced_programme_cache' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to PruneBalancedProgrammeCacheJob' do
    job = double(PruneBalancedProgrammeCacheJob)
    expect(PruneBalancedProgrammeCacheJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
