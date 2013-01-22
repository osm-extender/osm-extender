class AddConfirmByDateToSharedEvent < ActiveRecord::Migration
  def change
    add_column :shared_events, :confirm_by_date, :date
  end
end
