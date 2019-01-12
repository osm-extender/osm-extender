class EditableParams < Struct.new(:for_user)

  def announcement
    [
      :start, :finish, :title, :message, :prevent_hiding, :public,
      :start_date, :start_time, :finish_date, :finish_time
    ]
  end

  def contact_us
    [:name, :email_address, :message]
  end

  def email_list
    [
      :name, :section_id,
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

  def user
    if for_user && for_user.can_administer_users?
      [
        :name, :email_address,
        :can_administer_users, :can_view_statistics, :can_view_status,
        :can_administer_announcements, :can_administer_delayed_job,
        :can_become_other_user
      ]
    else
      []
    end
  end

end
