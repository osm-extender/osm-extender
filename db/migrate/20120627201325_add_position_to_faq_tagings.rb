class AddPositionToFaqTagings < ActiveRecord::Migration
  def change
    add_column :faq_tagings, :position, :integer, :default => 0, :null => false
  end
end
