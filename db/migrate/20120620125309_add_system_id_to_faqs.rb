class AddSystemIdToFaqs < ActiveRecord::Migration
  def change
    add_column :faqs, :system_id, :integer, :null => true, :default => nil
  end
end
