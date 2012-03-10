class Session < ActiveRecord::Base

  def self.delete_old_sessions(inactive_for=1.hour, total_age=6.hours)
    if inactive_for.is_a?(String)
      inactive_for = inactive_for.split.inject { |count, unit| count.to_i.send(unit) }
    end
    if total_age.is_a?(String)
      total_age = total_age.split.inject { |count, unit| count.to_i.send(unit) }
    end

    destroy_all ['updated_at < ? OR created_at < ?', inactive_for.ago.to_s(:db), total_age.ago.to_s(:db)]
  end

end