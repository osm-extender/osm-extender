class RemoveSessions < ActiveRecord::Migration
  def up
    drop_table :sessions
  end

  def down
    create_table "sessions", force: :cascade do |t|
      t.string   "session_id", null: false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
    end

    add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
    add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
    add_index "sessions", ["user_id"], name: "index_sessions_on_user_id", using: :btree
  end
end
