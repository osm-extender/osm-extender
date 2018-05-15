describe 'rake scheduled:reminder_emails' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Delegates to ReminderEmailsJob' do
    job = double(ReminderEmailsJob)
    expect(ReminderEmailsJob).to receive(:new).and_return(job)
    expect(job).to receive(:perform_now).and_return(nil)
    expect { task.execute }.not_to raise_error
  end

end
