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

ActiveRecord::Schema.define(:version => 20130121083109) do

  create_table "announcements", :force => true do |t|
    t.datetime "emailed_at"
    t.text     "message"
    t.datetime "start"
    t.datetime "finish"
    t.boolean  "public"
    t.boolean  "prevent_hiding"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

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
    t.boolean  "notify_changed",                       :default => false, :null => false
    t.string   "last_hash_of_addresses", :limit => 64, :default => "",    :null => false
  end

  add_index "email_lists", ["notify_changed"], :name => "index_email_lists_on_notify_changed"

  create_table "email_reminder_items", :force => true do |t|
    t.integer  "email_reminder_id"
    t.string   "type"
    t.text     "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",          :default => 0, :null => false
  end

  add_index "email_reminder_items", ["email_reminder_id"], :name => "index_email_reminder_items_on_email_reminder_id"
  add_index "email_reminder_items", ["type"], :name => "index_email_reminder_items_on_type"

  create_table "email_reminder_shares", :force => true do |t|
    t.integer  "reminder_id",                                        :null => false
    t.string   "email_address",                                      :null => false
    t.string   "name",                                               :null => false
    t.string   "state",         :limit => 16, :default => "pending", :null => false
    t.string   "auth_code",     :limit => 64,                        :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "email_reminder_shares", ["auth_code"], :name => "index_email_reminder_shares_on_auth_code"
  add_index "email_reminder_shares", ["reminder_id", "email_address"], :name => "index_email_reminder_shares_on_reminder_id_and_email_address", :unique => true
  add_index "email_reminder_shares", ["reminder_id"], :name => "index_email_reminder_shares_on_reminder_id"

  create_table "email_reminders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.integer  "send_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_name", :null => false
  end

  create_table "emailed_announcements", :force => true do |t|
    t.integer  "announcement_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "emailed_announcements", ["announcement_id"], :name => "index_emailed_announcements_on_announcement_id"
  add_index "emailed_announcements", ["user_id"], :name => "index_emailed_announcements_on_user_id"

  create_table "hidden_announcements", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "announcement_id", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "hidden_announcements", ["announcement_id", "user_id"], :name => "index_hidden_announcements_on_announcement_id_and_user_id", :unique => true
  add_index "hidden_announcements", ["announcement_id"], :name => "index_hidden_announcements_on_announcement_id"
  add_index "hidden_announcements", ["user_id", "announcement_id"], :name => "index_hidden_announcements_on_user_id_and_announcement_id", :unique => true
  add_index "hidden_announcements", ["user_id"], :name => "index_hidden_announcements_on_user_id"

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

  create_table "shared_event_attendances", :force => true do |t|
    t.integer  "shared_event_id", :null => false
    t.integer  "user_id",         :null => false
    t.integer  "section_id",      :null => false
    t.integer  "event_id",        :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "shared_event_attendances", ["shared_event_id"], :name => "index_shared_event_attendances_on_shared_event_id"
  add_index "shared_event_attendances", ["user_id"], :name => "index_shared_event_attendances_on_user_id"

  create_table "shared_event_field_data", :force => true do |t|
    t.integer  "shared_event_field_id",      :null => false
    t.integer  "shared_event_attendance_id", :null => false
    t.string   "source_type",                :null => false
    t.integer  "source_id"
    t.string   "source_field",               :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "shared_event_field_data", ["shared_event_attendance_id"], :name => "index_shared_event_field_data_on_shared_event_attendance_id"
  add_index "shared_event_field_data", ["shared_event_field_id"], :name => "index_shared_event_field_data_on_shared_event_field_id"

  create_table "shared_event_fields", :force => true do |t|
    t.integer  "shared_event_id", :null => false
    t.string   "name",            :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "shared_event_fields", ["shared_event_id"], :name => "index_shared_event_fields_on_shared_event_id"

  create_table "shared_events", :force => true do |t|
    t.string   "name",            :null => false
    t.date     "start_date"
    t.string   "start_time"
    t.date     "finish_date"
    t.string   "finish_time"
    t.string   "cost"
    t.string   "location"
    t.text     "notes"
    t.integer  "user_id",         :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "confirm_by_date"
  end

  add_index "shared_events", ["user_id"], :name => "index_shared_events_on_user_id"

  create_table "statistics", :force => true do |t|
    t.date     "date",                         :null => false
    t.integer  "users"
    t.integer  "email_reminders"
    t.text     "email_reminders_by_day"
    t.text     "email_reminders_by_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.text     "email_reminder_shares_by_day"
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
    t.boolean  "can_administer_settings",                       :default => false
    t.boolean  "can_view_statistics",                           :default => false
    t.integer  "startup_section",                               :default => 0,     :null => false
    t.boolean  "can_administer_announcements",                  :default => false
    t.boolean  "can_administer_delayed_job",                    :default => false
    t.boolean  "can_become_other_user",                         :default => false
    t.integer  "custom_row_height",                             :default => 0
    t.integer  "custom_text_size",                              :default => 0
  end

end
