describe 'rake scheduled:delete_nonactivated_users' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to PruneUnactivatedUsersJob' do
    job = double(PruneUnactivatedUsersJob)
    expect(PruneUnactivatedUsersJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
