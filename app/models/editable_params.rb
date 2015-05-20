class EditableParams < Struct.new(:for_user)

  def announcement
    [
      :start, :finish, :message, :prevent_hiding, :public,
      :start_date, :start_time, :finish_date, :finish_time
    ]
  end

  def contact_us
    [:name, :email_address, :message]
  end

  def email_list
    [
      :name, :section_id, :email1, :email2, :email3, :email4,
      :contact_member, :contact_primary, :contact_secondary, :contact_emergency,
      :match_type, :match_grouping, :notify_changed
    ]
  end

  def email_reminder
    [:section_id, :send_on]
  end

  def email_reminder_share
    [:email_address, :name]
  end

  def email_reminder_subscription
    [:email_address, :name]
  end

end

#  def topic
#    if for_user && for_user.admin?
#      [:name]
#    else
#      [:name, :option]
#    end
#  end
