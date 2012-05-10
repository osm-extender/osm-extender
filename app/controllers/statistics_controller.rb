class StatisticsController < ApplicationController

  def users
    return unless require_osmx_permission(:administer_users)

    respond_to do |format|
      format.html # users.html.erb
      format.json { render json: users_data }
    end
  end

  def email_reminders
    return unless require_osmx_permission(:administer_users)

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
    users = Array.new
    cumulative_total = 0
    largest = 0
    earliest = User.minimum(:created_at).to_date
    ((earliest - 1)..Date.today).each do |date|
      new = User.where(['created_at >= ? AND created_at < ?', date, date+1]).count
      cumulative_total += new
      largest = cumulative_total if cumulative_total > largest
      users.push ({
        :date => date,
        :total => cumulative_total,
        :new => new
      })
    end

    return {
      :users => {
        :data => users,
        :max_value => largest
      }
    }
  end

  def email_reminders_data
    number = Array.new
    cumulative_total = 0
    largest = 0
    earliest = User.minimum(:created_at).to_date
    (earliest..Date.today).each do |date|
      new = EmailReminder.where(['created_at >= ? AND created_at < ?', date, date+1]).count
      cumulative_total += new
      largest = cumulative_total if cumulative_total > largest
      number.push ({
        :date => date,
        :total => cumulative_total,
        :new => new
      })
    end

    return {
      :reminders => {
        :data => number,
        :max_value => largest
      }
    }
  end

end