class Session < ActiveRecord::Base
  serialize :data, Base64MarshalSerializer
  belongs_to :user

  scope :guests, -> { where(user_id: nil) }
  scope :users, -> { where.not(user_id: nil) }

  def self.delete_old_sessions
    destroy_all ['updated_at < ?', Rails.application.config.sorcery.session_timeout.seconds.ago.to_s(:db)]
  end

end
