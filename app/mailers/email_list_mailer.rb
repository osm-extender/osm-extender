class EmailListMailer < ApplicationMailer

  def changed(email_list)
    @email_list = email_list
    mail ({
      :subject => build_subject('Email List Changed'),
      :to => @email_list.user.email_address_with_name
    })
  end

  def no_current_term(email_list, exception)
    @email_list = email_list
    user = @email_list.user

    unless user.nil? || !user.connected_to_osm? || @email_list.section_id.nil?
      api = user.osm_api
      @next_term = nil
      @last_term = nil
      terms = Osm::Term.get_for_section(api, @email_list.section)
      terms.each do |term|
        @last_term = term if term.past? && (@last_term.nil? || term.finish > @last_term.finish)
        @next_term = term if term.future? && (@next_term.nil? || term.start < @next_term.start)
      end
    end

    mail ({
      :subject => build_subject('Checking Email List For Changes FAILED'),
      :to => @email_list.user.email_address_with_name
    })
  end

  def forbidden(email_list, exception)
    @email_list = email_list

    mail ({
      :subject => build_subject('Checking Email List For Changes FAILED'),
      :to => @email_list.user.email_address_with_name
    })
  end


end
