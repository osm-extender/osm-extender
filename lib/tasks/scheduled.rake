namespace :scheduled  do

  def exception_raised(task, exception)
    puts "\t\tAn Exception was raised (#{exception.message})"
    Rollbar.error(exception)
  end

  task :monthly => ['clean:all']
  task :daily => [:automation_tasks, :reminder_emails, :email_lists, :statistics]
  task :hourly => [:delete_old_sessions, :delete_nonactivated_users]

end
