# Move getting usage stats to model
#  Generate past usage stats in migration too

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

  def sections
    respond_to do |format|
      format.html # sections.html.erb
      format.json { render json: Statistics.sections }
    end
  end

  def usage
    respond_to do |format|
      format.html # usage.html.erb
      format.json { render json: usage_data }
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
        :total => cache['users']
      })
      users_max = cache['users'] if cache['users'] > users_max
    end

    weekly_signins_last_week_hash = UsageLog.where('at >= ?', 6.days.ago.to_date).where(:controller => 'SessionsController', :action => 'create', :result => 'success').count(:group => [:at_day_of_week, :at_hour])
    weekly_signins_last_4_weeks_hash = UsageLog.where('at >= ? AND at < ?', 29.days.ago.to_date, Date.today).where(:controller => 'SessionsController', :action => 'create', :result => 'success').count(:group => [:at_day_of_week, :at_hour])
    weekly_signins_label = []
    weekly_signins_last_week = []
    weekly_signins_last_4_weeks = []
    (0..6).each do |dow|
      day_name = Date::DAYNAMES[dow][0..2]
      (0..23).each do |hour|
        weekly_signins_label.push "#{day_name} #{hour.to_s.rjust(2, '0')}-#{(hour+1).to_s.rjust(2, '0')}"
        weekly_signins_last_week.push(weekly_signins_last_week_hash[[dow, hour]] || 0)
        weekly_signins_last_4_weeks.push((weekly_signins_last_4_weeks_hash[[dow, hour]] || 0) / 4.0)
      end
    end
    signins = []
    signins_hash = UsageLog.where(:controller => 'SessionsController', :action => 'create', :result => 'success').count(:user_id, :distinct => true, :group => 'DATE(at)')
    earliest_signin = UsageLog.minimum(:at).to_date
    (earliest_signin..Date.today).each do |date|
      value = signins_hash[date.strftime('%Y-%m-%d')]
      signins.push({
        :date => date,
        :total => (value ? value : 0),
      })
    end

    return {
      'users' => {
        'data' => users,
        'max_value' => users_max
      },
      'weekly_signins' => {
        'label' => weekly_signins_label,
        'last_week' => weekly_signins_last_week,
        'last_4_weeks' => weekly_signins_last_4_weeks,
        'max_value' => [weekly_signins_last_week.max, weekly_signins_last_4_weeks.max].max,
        'count' => weekly_signins_label.count,
      },
      'signins' => {
        'data' => signins,
        'max_value' => signins_hash.values.max,
      }
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
        :total => cache['email_reminders']
      })
      number_max = cache['email_reminders'] if cache['email_reminders'] > number_max
    end

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

  def usage_data
    nonunique = []
    unique_usersection = []
    unique_all = []

    earliest = UsageLog.where(['DATE(at) > ?', 1.year.ago.to_date]).minimum(:at).to_date
    (earliest..Date.today).each do |date|
      cache = Statistics.create_or_retrieve_for_date(date)
      nonunique.push(cache['usage']['nonunique'].merge({:date => date}))
      unique_usersection.push(cache['usage']['unique_usersection'].merge({:date => date}))
      unique_all.push(cache['usage']['unique_all'].merge({:date => date}))
    end

    return {
      :unique_all => {
        :data => unique_all,
        :max_value => unique_all.map{|i| i.except(:date).values.max }.select{ |i| !i.nil? }.max,
      },
      :unique_usersection => {
        :data => unique_usersection,
        :max_value => unique_usersection.map{|i| i.except(:date).values.max }.select{ |i| !i.nil? }.max,
      },
      :nonunique => {
        :data => nonunique,
        :max_value => nonunique.map{|i| i.except(:date).values.max }.select{ |i| !i.nil? }.max,
      },
    }
  end

end