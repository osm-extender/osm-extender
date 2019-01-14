class RemoveCanAdministerFaqsFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :can_administer_faqs
  end

  def down
    add_column :users, :can_administer_faqs, :boolean, :default => false
  end
end
