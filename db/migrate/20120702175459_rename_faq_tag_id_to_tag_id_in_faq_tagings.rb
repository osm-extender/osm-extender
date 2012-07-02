class RenameFaqTagIdToTagIdInFaqTagings < ActiveRecord::Migration
  def self.up
    remove_index :faq_tagings, :faq_tag_id
    remove_index :faq_tagings, [:faq_id, :faq_tag_id]

    rename_column :faq_tagings, :faq_tag_id, :tag_id

    add_index :faq_tagings, :tag_id
    add_index :faq_tagings, [:faq_id, :tag_id], :unique=>true
  end


  def self.down
    remove_index :faq_tagings, :tag_id
    remove_index :faq_tagings, [:faq_id, :tag_id]

    rename_column :faq_tagings, :tag_id, :faq_tag_id

    add_index :faq_tagings, :faq_tag_id
    add_index :faq_tagings, [:faq_id, :faq_tag_id], :unique=>true
  end
end