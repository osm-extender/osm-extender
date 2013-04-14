class DeleteAllSessions < ActiveRecord::Migration
  def up
    # Old sessions are incompatible (current_section is stored as an ID now)
    Session.delete_all
  end
end
