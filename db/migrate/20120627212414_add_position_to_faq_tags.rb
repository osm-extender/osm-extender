class AddPositionToFaqTags < ActiveRecord::Migration
  def change
    add_column :faq_tags, :position, :integer, :default => 0, :null => false
  end
end
