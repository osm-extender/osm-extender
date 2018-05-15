describe 'rake scheduled:clean:announcements' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to PruneAnnouncementsJob' do
    job = double(PruneAnnouncementsJob)
    expect(PruneAnnouncementsJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
