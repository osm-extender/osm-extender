class AddAutomationTasksToStatistics < ActiveRecord::Migration[4.2]
  def change
    add_column :statistics, :automation_tasks, :text
  end
end
