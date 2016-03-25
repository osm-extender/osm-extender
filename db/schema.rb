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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160321111358) do

  create_table "announcements", force: :cascade do |t|
    t.text     "message",                        null: false
    t.datetime "start",                          null: false
    t.datetime "finish",                         null: false
    t.boolean  "public",         default: false, null: false
    t.boolean  "prevent_hiding", default: false, null: false
    t.datetime "emailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index"
  add_index "audits", ["created_at"], name: "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], name: "user_index"

  create_table "automation_tasks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "section_id",                   null: false
    t.string   "type",                         null: false
    t.boolean  "active",        default: true, null: false
    t.text     "configuration"
    t.string   "section_name",                 null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "automation_tasks", ["active"], name: "index_automation_tasks_on_active"
  add_index "automation_tasks", ["section_id"], name: "index_automation_tasks_on_section_id"
  add_index "automation_tasks", ["user_id"], name: "index_automation_tasks_on_user_id"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "email_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.string   "name"
    t.boolean  "match_type"
    t.integer  "match_grouping"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notify_changed",                    default: false, null: false
    t.string   "last_hash_of_addresses", limit: 64, default: "",    null: false
    t.integer  "contact_member",                    default: 0,     null: false
    t.integer  "contact_primary",                   default: 0,     null: false
    t.integer  "contact_secondary",                 default: 0,     null: false
    t.integer  "contact_emergency",                 default: 0,     null: false
  end

  add_index "email_lists", ["notify_changed"], name: "index_email_lists_on_notify_changed"
  add_index "email_lists", ["section_id"], name: "index_email_lists_on_section_id"
  add_index "email_lists", ["user_id"], name: "index_email_lists_on_user_id"

  create_table "email_reminder_items", force: :cascade do |t|
    t.integer  "email_reminder_id"
    t.string   "type"
    t.text     "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",          default: 0, null: false
  end

  add_index "email_reminder_items", ["email_reminder_id"], name: "index_email_reminder_items_on_email_reminder_id"
  add_index "email_reminder_items", ["type"], name: "index_email_reminder_items_on_type"

  create_table "email_reminder_shares", force: :cascade do |t|
    t.integer  "reminder_id",                                   null: false
    t.string   "email_address",                                 null: false
    t.string   "name",                                          null: false
    t.string   "state",         limit: 16,  default: "pending", null: false
    t.string   "auth_code",     limit: 128,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_reminder_shares", ["auth_code"], name: "index_email_reminder_shares_on_auth_code"
  add_index "email_reminder_shares", ["reminder_id", "email_address"], name: "index_email_reminder_shares_on_reminder_id_and_email_address", unique: true
  add_index "email_reminder_shares", ["reminder_id"], name: "index_email_reminder_shares_on_reminder_id"

  create_table "email_reminders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.integer  "send_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section_name", null: false
  end

  add_index "email_reminders", ["section_id"], name: "index_email_reminders_on_section_id"
  add_index "email_reminders", ["send_on"], name: "index_email_reminders_on_send_on"
  add_index "email_reminders", ["user_id"], name: "index_email_reminders_on_user_id"

  create_table "emailed_announcements", force: :cascade do |t|
    t.integer  "announcement_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emailed_announcements", ["announcement_id"], name: "index_emailed_announcements_on_announcement_id"
  add_index "emailed_announcements", ["user_id"], name: "index_emailed_announcements_on_user_id"

  create_table "hidden_announcements", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "announcement_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hidden_announcements", ["announcement_id", "user_id"], name: "index_hidden_announcements_on_announcement_id_and_user_id", unique: true
  add_index "hidden_announcements", ["announcement_id"], name: "index_hidden_announcements_on_announcement_id"
  add_index "hidden_announcements", ["user_id", "announcement_id"], name: "index_hidden_announcements_on_user_id_and_announcement_id", unique: true
  add_index "hidden_announcements", ["user_id"], name: "index_hidden_announcements_on_user_id"

  create_table "programme_review_balanced_caches", force: :cascade do |t|
    t.integer  "term_id",      null: false
    t.integer  "section_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_used_at"
    t.text     "data"
    t.string   "term_name",    null: false
    t.date     "term_start",   null: false
    t.date     "term_finish",  null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "statistics", force: :cascade do |t|
    t.date     "date",                         null: false
    t.integer  "users"
    t.integer  "email_reminders"
    t.text     "email_reminders_by_day"
    t.text     "email_reminders_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "email_reminder_shares_by_day"
    t.text     "usage"
    t.text     "automation_tasks"
  end

  add_index "statistics", ["date"], name: "index_statistics_on_date", unique: true

  create_table "usage_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.string   "controller",     null: false
    t.string   "action",         null: false
    t.string   "sub_action"
    t.string   "result"
    t.text     "extra_details"
    t.datetime "at",             null: false
    t.integer  "at_day_of_week", null: false
    t.integer  "at_hour",        null: false
  end

  add_index "usage_logs", ["action"], name: "index_usage_logs_on_action"
  add_index "usage_logs", ["at"], name: "index_usage_logs_on_at"
  add_index "usage_logs", ["section_id"], name: "index_usage_logs_on_section_id"
  add_index "usage_logs", ["user_id"], name: "index_usage_logs_on_user_id"

  create_table "user_versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "user_versions", ["item_type", "item_id"], name: "index_user_versions_on_item_type_and_item_id"

  create_table "users", force: :cascade do |t|
    t.string   "email_address",                                              null: false
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
    t.integer  "failed_logins_count",                        default: 0
    t.datetime "lock_expires_at"
    t.string   "name"
    t.boolean  "can_administer_users",                       default: false
    t.text     "osm_userid",                      limit: 6
    t.text     "osm_secret",                      limit: 32
    t.boolean  "can_view_statistics",                        default: false
    t.integer  "startup_section",                            default: 0,     null: false
    t.boolean  "can_administer_announcements",               default: false
    t.boolean  "can_administer_delayed_job",                 default: false
    t.boolean  "can_become_other_user",                      default: false
    t.integer  "custom_row_height",                          default: 0
    t.integer  "custom_text_size",                           default: 0
    t.string   "unlock_token"
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token"
  add_index "users", ["email_address"], name: "index_users_on_email_address", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token"
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token"

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  validates("email_lists", "contact_member", inclusion: { in: 0..4 })
  validates("email_lists", "contact_primary", inclusion: { in: 0..4 })
  validates("email_lists", "contact_secondary", inclusion: { in: 0..4 })
  validates("email_lists", "contact_emergency", inclusion: { in: 0..3 })

end
