class DropFaqTables < ActiveRecord::Migration
  def up
    drop_table :faqs
    drop_table :faq_tags
    drop_table :faq_tagings
  end

  def down
    create_table "faq_tagings", :force => true do |t|
      t.integer  "faq_id",                    :null => false
      t.integer  "tag_id",                    :null => false
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
      t.integer  "position",   :default => 0, :null => false
    end
  
    add_index "faq_tagings", ["faq_id", "tag_id"], :name => "index_faq_tagings_on_faq_id_and_tag_id", :unique => true
    add_index "faq_tagings", ["faq_id"], :name => "index_faq_tagings_on_faq_id"
    add_index "faq_tagings", ["tag_id"], :name => "index_faq_tagings_on_tag_id"
  
    create_table "faq_tags", :force => true do |t|
      t.string   "name",                      :null => false
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
      t.integer  "position",   :default => 0, :null => false
    end
  
    add_index "faq_tags", ["name"], :name => "index_faq_tags_on_name", :unique => true
  
    create_table "faqs", :force => true do |t|
      t.string   "question"
      t.text     "answer"
      t.boolean  "active",     :default => true
      t.datetime "created_at",                   :null => false
      t.datetime "updated_at",                   :null => false
      t.integer  "system_id"
    end
  end
end
