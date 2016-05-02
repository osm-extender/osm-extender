class AutomationTaskMailer < ApplicationMailer

  def errors(task, errors)
    @task = task
    @errors = errors

    mail ({
      :subject => build_subject('Performing Automation Tasks FAILED - Error'),
      :to => @task.user.email_address_with_name
    })
  end

  def no_current_term(task, exception)
    @task = task
    user = task.user

    unless user.nil? || !user.connected_to_osm? || @task.section_id.nil?
      api = user.osm_api
      @next_term = nil
      @last_term = nil
      terms = Osm::Term.get_for_section(api, @task.section)
      terms.each do |term|
        @last_term = term if term.past? && (@last_term.nil? || term.finish > @last_term.finish)
        @next_term = term if term.future? && (@next_term.nil? || term.start < @next_term.start)
      end
    end

    mail ({
      :subject => build_subject('Performing Automation Tasks FAILED - No Current Term'),
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
