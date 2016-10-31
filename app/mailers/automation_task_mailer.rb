class AutomationTaskMailer < ApplicationMailer

  def errors(task, errors)
    @task = task
    @errors = errors

    mail ({
      :subject => build_subject('Performing Automation Tasks FAILED - Error'),
      :to => @task.user.email_address_with_name
    })
  end

  def forbidden(task, exception)
    @task = task

    mail ({
      :subject => build_subject('Performing Automation Tasks FAILED - Forbidden'),
      :to => @task.user.email_address_with_name
    })
  end

end
