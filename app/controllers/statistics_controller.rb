class StatisticsController < ApplicationController
  before_filter { require_osmx_permission :view_statistics }

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

    todays_data = StatisticsCache.create_or_retrieve_for_date(Date.today)

    by_day = todays_data.email_reminders_by_day
    by_day_max = 0
    by_day.each do |count|
      by_day_max = count if count > by_day_max
    end

    items = Hash.new
    items_max = 0
    todays_data.email_reminders_by_type.each do |key, value|
      items_max = value if value > items_max
      items[Kernel.const_get(key).new.friendly_name] = value
    end

    return {
      :number => {
        :data => number,
        :max_value => StatisticsCache.maximum(:email_reminders)
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