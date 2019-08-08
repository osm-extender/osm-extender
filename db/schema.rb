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

ActiveRecord::Schema.define(version: 2019_08_08_124831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.text "message", null: false
    t.datetime "start", null: false
    t.datetime "finish", null: false
    t.boolean "public", default: false, null: false
    t.boolean "prevent_hiding", default: false, null: false
    t.datetime "emailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
  end

  create_table "automation_tasks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "section_id", null: false
    t.string "type", null: false
    t.boolean "active", default: true, null: false
    t.text "configuration"
    t.string "section_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_automation_tasks_on_active"
    t.index ["section_id"], name: "index_automation_tasks_on_section_id"
    t.index ["user_id"], name: "index_automation_tasks_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_lists", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "section_id"
    t.string "name"
    t.boolean "match_type"
    t.integer "match_grouping"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "notify_changed", default: false, null: false
    t.string "last_hash_of_addresses", limit: 64, default: "", null: false
    t.integer "contact_member", default: 0, null: false
    t.integer "contact_primary", default: 0, null: false
    t.integer "contact_secondary", default: 0, null: false
    t.integer "contact_emergency", default: 0, null: false
    t.index ["notify_changed"], name: "index_email_lists_on_notify_changed"
    t.index ["section_id"], name: "index_email_lists_on_section_id"
    t.index ["user_id"], name: "index_email_lists_on_user_id"
  end

  create_table "email_reminder_items", id: :serial, force: :cascade do |t|
    t.integer "email_reminder_id"
    t.string "type"
    t.text "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position", default: 0, null: false
    t.index ["email_reminder_id"], name: "index_email_reminder_items_on_email_reminder_id"
    t.index ["type"], name: "index_email_reminder_items_on_type"
  end

  create_table "email_reminder_shares", id: :serial, force: :cascade do |t|
    t.integer "reminder_id", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "state", limit: 16, default: "pending", null: false
    t.string "auth_code", limit: 128, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["auth_code"], name: "index_email_reminder_shares_on_auth_code"
    t.index ["reminder_id", "email_address"], name: "index_email_reminder_shares_on_reminder_id_and_email_address", unique: true
    t.index ["reminder_id"], name: "index_email_reminder_shares_on_reminder_id"
  end

  create_table "email_reminders", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "section_id"
    t.integer "send_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "section_name", null: false
    t.index ["section_id"], name: "index_email_reminders_on_section_id"
    t.index ["send_on"], name: "index_email_reminders_on_send_on"
    t.index ["user_id"], name: "index_email_reminders_on_user_id"
  end

  create_table "emailed_announcements", id: :serial, force: :cascade do |t|
    t.integer "announcement_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["announcement_id"], name: "index_emailed_announcements_on_announcement_id"
    t.index ["user_id"], name: "index_emailed_announcements_on_user_id"
  end

  create_table "hidden_announcements", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "announcement_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["announcement_id", "user_id"], name: "index_hidden_announcements_on_announcement_id_and_user_id", unique: true
    t.index ["announcement_id"], name: "index_hidden_announcements_on_announcement_id"
    t.index ["user_id", "announcement_id"], name: "index_hidden_announcements_on_user_id_and_announcement_id", unique: true
    t.index ["user_id"], name: "index_hidden_announcements_on_user_id"
  end

  create_table "programme_review_balanced_caches", id: :serial, force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "section_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_used_at"
    t.text "data"
    t.string "term_name", null: false
    t.date "term_start", null: false
    t.date "term_finish", null: false
  end

  create_table "statistics", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.integer "users"
    t.integer "email_reminders"
    t.text "email_reminders_by_day"
    t.text "email_reminders_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "email_reminder_shares_by_day"
    t.text "automation_tasks"
    t.index ["date"], name: "index_statistics_on_date", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.citext "email_address", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "name"
    t.boolean "can_administer_users", default: false
    t.text "osm_userid"
    t.text "osm_secret"
    t.boolean "can_view_statistics", default: false
    t.integer "startup_section", default: 0, null: false
    t.boolean "can_administer_announcements", default: false
    t.boolean "can_administer_delayed_job", default: false
    t.boolean "can_become_other_user", default: false
    t.integer "custom_row_height", default: 0
    t.integer "custom_text_size", default: 0
    t.string "unlock_token"
    t.boolean "can_view_status", default: false
    t.datetime "gdpr_consent_at"
    t.index ["activation_token"], name: "index_users_on_activation_token"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "automation_tasks", "users"
end
