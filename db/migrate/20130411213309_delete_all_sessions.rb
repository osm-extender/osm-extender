class DeleteAllSessions < ActiveRecord::Migration[4.2]
  def up
    # Old sessions are incompatible (current_section is stored as an ID now)
    Session.delete_all if defined?(Session)
  end
end
