namespace :scheduled  do

  def exception_raised(task, exception)
    puts "\t\tAn Exception was raised (#{exception.message})"
    Rollbar.error(exception)
  end

  task :daily => [:automation_tasks, :reminder_emails, :email_lists, :statistics, :delete_nonactivated_users]

end
