class AddAutomationTasksToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :automation_tasks, :text
  end
end
