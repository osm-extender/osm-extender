# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120523143413) do

  create_table "email_lists", :force => true do |t|
    t.text     "name"
    t.integer  "user_id"
    t.integer  "section_id"
    t.boolean  "email1"
    t.boolean  "email2"
    t.boolean  "email3"
    t.boolean  "email4"
    t.boolean  "match_type"
    t.integer  "match_grouping"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_reminder_items", :force => true do |t|
    t.integer  "email_reminder_id"
    t.string   "type"
    t.text     "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_reminder_items", ["email_reminder_id"], :name => "index_email_reminder_items_on_email_reminder_id"
  add_index "email_reminder_items", ["type"], :name => "index_email_reminder_items_on_type"

  create_table "email_reminders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.integer  "send_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faqs", :force => true do |t|
    t.string   "question"
    t.text     "answer"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programme_review_balanced_caches", :force => true do |t|
    t.integer  "section_id"
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_used_at"
    t.text     "data"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "setting_values", :force => true do |t|
    t.text "key",         :limit => 255, :null => false
    t.text "value"
    t.text "description",                :null => false
  end

  create_table "statistics", :force => true do |t|
    t.date     "date",                    :null => false
    t.integer  "users"
    t.integer  "email_reminders"
    t.text     "email_reminders_by_day"
    t.text     "email_reminders_by_type"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "statistics", ["date"], :name => "index_statistics_caches_on_date", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email_address"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer  "failed_logins_count"
    t.datetime "lock_expires_at"
    t.string   "name"
    t.boolean  "can_administer_users"
    t.text     "osm_userid",                      :limit => 6
    t.text     "osm_secret",                      :limit => 32
    t.boolean  "can_administer_faqs",                           :default => false
    t.boolean  "can_administer_settings",                       :default => false
    t.boolean  "can_view_statistics",                           :default => false
  end

end
