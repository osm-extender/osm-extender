class AddConfirmByDateToSharedEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :shared_events, :confirm_by_date, :date
  end
end
