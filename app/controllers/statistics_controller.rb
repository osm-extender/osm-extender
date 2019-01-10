class StatisticsController < ApplicationController
  before_action { require_osmx_permission :view_statistics }

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

  def sections
    respond_to do |format|
      format.html # sections.html.erb
      format.json { render json: Statistics.sections }
    end
  end

  def automation_tasks
    respond_to do |format|
      format.html # automated_tasks.html.erb
      format.json { render json: Statistics.get_automation_tasks_data(Date.today) }
    end
  end


  private
  def users_data
    {
      'data' => Statistics.order(date: :asc).pluck(:date, :users),
      'max_value' => Statistics.maximum(:users)
    }
  end

  def email_reminders_data
    todays_data = Statistics.create_or_retrieve_for_date(Date.today)

    by_day = [todays_data['email_reminders_by_day'], todays_data['email_reminder_shares_by_day']]
    by_day_max = 0
    (0..6).each do |i|
      count = by_day[0][i] + by_day[1][i]['pending'] + by_day[1][i]['subscribed'] + by_day[1][i]['unsubscribed']
      by_day_max = count if count > by_day_max
    end

    items = Hash.new
    items_max = 0
    todays_data['email_reminders_by_type'].each do |key, value|
      items_max = value if value > items_max
      items[Kernel.const_get(key).human_name] = value
    end

    return {
      :number => {
        :data => Statistics.order(date: :asc).pluck(:date, :email_reminders),
        :max_value => Statistics.maximum(:email_reminders)
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
