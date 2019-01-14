class AddCanAdministerFaqsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :can_administer_faqs, :boolean, :default => false
  end
end
