class StatisticsController < ApplicationController
  before_filter { require_osmx_permission :view_statistics }

  def index
  end

  def users
    respond_to do |format|
      format.html # users.html.erb
      format.json { render json: users_data }
    end
  end

  def email_reminders
    respond_to do |format|
      format.html # email_reminders.html.erb
      format.json { render json: email_reminders_data }
    end
  end


  private
  def users_data
    earliest = User.minimum(:created_at).to_date
    users_max = 0
    users = [{:date => (earliest - 1), :total => 0}]
    (earliest..Date.today).each do |date|
      cache = Statistics.create_or_retrieve_for_date(date)
      users.push ({
        :date => date,
        :total => cache.users
      })
      users_max = cache.users if cache.users > users_max
    end

    return {
      :data => users,
      :max_value => users_max
    }
  end

  def email_reminders_data
    earliest = User.minimum(:created_at).to_date

    number_max = 0
    number = [{:date => (earliest - 1), :total => 0}]
    (earliest..Date.today).each do |date|
      cache = Statistics.create_or_retrieve_for_date(date)
      number.push ({
        :date => date,
        :total => cache.email_reminders
      })
      number_max = cache.email_reminders if cache.email_reminders > number_max
    end

    todays_data = Statistics.create_or_retrieve_for_date(Date.today)

    by_day = [todays_data.email_reminders_by_day, todays_data.email_reminder_shares_by_day]
    by_day_max = 0
    (0..6).each do |i|
      count = by_day[0][i] + by_day[1][i]['pending'] + by_day[1][i]['subscribed'] + by_day[1][i]['unsubscribed']
      by_day_max = count if count > by_day_max
    end

    items = Hash.new
    items_max = 0
    todays_data.email_reminders_by_type.each do |key, value|
      items_max = value if value > items_max
      items[Kernel.const_get(key).human_name] = value
    end

    return {
      :number => {
        :data => number,
        :max_value => number_max
      },
      :day => {
        :data => by_day,
        :max_value => by_day_max
      },
      :item => {
        :data => items,
        :max_value => items_max
      }
    }
  end

end