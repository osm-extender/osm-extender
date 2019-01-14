class AddPositionToFaqTagings < ActiveRecord::Migration[4.2]
  def change
    add_column :faq_tagings, :position, :integer, :default => 0, :null => false
  end
end
