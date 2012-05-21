class StatisticsController < ApplicationController
  before_filter { require_osmx_permission :view_statistics }

  def users
    respond_to do |format|
      format.html # users.html.erb
      format.json { render json: users_data }
    end
  end

  def email_reminders
    @number_day = Array.new(7, 0)
    (0..6).each do |day|
      @number_day[day] += EmailReminder.where(['send_on = ?', day]).count
    end

    @items = Array.new
    from_db = EmailReminderItem.group(:type).count
    from_db.each_key do |key|
      @items.push ({
        :name => Kernel.const_get(key).new.friendly_name,
        :count => from_db[key]
      })
    end

    respond_to do |format|
      format.html # email_reminders.html.erb
      format.json { render json: email_reminders_data }
    end
  end


  private
  def users_data
    earliest = User.minimum(:created_at).to_date
    users = [{:date => (earliest - 1), :total => 0}]
    (earliest..Date.today).each do |date|
      cache = StatisticsCache.create_or_retrieve_for_date(date)
      users.push ({
        :date => date,
        :total => cache.users,
      })
    end

    return {
      :users => {
        :data => users,
        :max_value => StatisticsCache.maximum(:users)
      }
    }
  end

  def email_reminders_data
    earliest = User.minimum(:created_at).to_date
    number = [{:date => (earliest - 1), :total => 0}]
    (earliest..Date.today).each do |date|
      cache = StatisticsCache.create_or_retrieve_for_date(date)
      number.push ({
        :date => date,
        :total => cache.users,
      })
    end

    return {
      :reminders => {
        :data => number,
        :max_value => StatisticsCache.maximum(:email_reminders)
      }
    }
  end

end