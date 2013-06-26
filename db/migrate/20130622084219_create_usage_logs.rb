class CreateUsageLogs < ActiveRecord::Migration
  def change
    create_table :usage_logs do |t|
      t.references :user
      t.integer :section_id
      t.string :controller, :null => false
      t.string :action, :null => false
      t.string :sub_action
      t.string :result
      t.text :extra_details
      t.timestamp :at, :null => false
    end

    add_index :usage_logs, :user_id
    add_index :usage_logs, :section_id
    add_index :usage_logs, :action
    add_index :usage_logs, :at
  end
end
