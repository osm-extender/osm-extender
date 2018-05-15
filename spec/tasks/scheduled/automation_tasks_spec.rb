describe 'rake scheduled:automation_tasks' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to AutomationTasksJob' do
    job = double(AutomationTasksJob)
    expect(AutomationTasksJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
