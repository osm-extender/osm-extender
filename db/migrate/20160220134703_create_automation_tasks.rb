class CreateAutomationTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :automation_tasks do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :section_id, index: true, null: false
      t.string :type, :null => false
      t.boolean :active, index: true, null: false, default: true
      t.text :configuration, null: true
      t.string :section_name, null: false

      t.timestamps null: false

    end
  end
end
