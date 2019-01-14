class AddSystemIdToFaqs < ActiveRecord::Migration[4.2]
  def change
    add_column :faqs, :system_id, :integer, :null => true, :default => nil
  end
end
