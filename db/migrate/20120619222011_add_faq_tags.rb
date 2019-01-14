class AddFaqTags < ActiveRecord::Migration[4.2]

  def up
    create_table :faq_tags do |t|
      t.string :name, :null => false

      t.timestamps
    end
    add_index :faq_tags, :name, :unique => true

    create_table :faq_tagings do |t|
      t.references :faq, :null => false
      t.references :faq_tag, :null => false

      t.timestamps
    end
    add_index :faq_tagings, :faq_id
    add_index :faq_tagings, :faq_tag_id
    add_index :faq_tagings, [:faq_id, :faq_tag_id], :unique=>true
  end


  def down
    drop_table :faq_tags
    drop_table :faq_tagings
  end
end
