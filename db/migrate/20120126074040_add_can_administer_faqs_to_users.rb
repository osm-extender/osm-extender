class AddCanAdministerFaqsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_administer_faqs, :boolean, :default => false
  end
end
