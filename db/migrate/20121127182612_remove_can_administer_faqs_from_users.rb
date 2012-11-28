class RemoveCanAdministerFaqsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :can_administer_faqs
  end

  def down
    add_column :users, :can_administer_faqs, :boolean, :default => false
  end
end
