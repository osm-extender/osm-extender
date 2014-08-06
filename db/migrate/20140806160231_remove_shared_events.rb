class RemoveSharedEvents < ActiveRecord::Migration

  class SharedEvent < ActiveRecord::Base; end
  class SharedEventField < ActiveRecord::Base; end
  class SharedEventAttendance < ActiveRecord::Base; end
  class SharedEventFieldData < ActiveRecord::Base; end

  class SharedEvent < ActiveRecord::Base
    has_paper_trail
    belongs_to :user
    has_many :attendance, dependent: :destroy, class_name: SharedEventAttendance, inverse_of: :shared_event
    has_many :fields, dependent: :destroy, class_name: SharedEventField, inverse_of: :shared_event
  end
  class SharedEventField < ActiveRecord::Base
    has_paper_trail
    belongs_to :event, :class_name => SharedEvent, :foreign_key => :shared_event_id
    belongs_to :shared_event
    has_many :data_sources, dependent: :destroy, class_name: SharedEventFieldData, inverse_of: :shared_event_field
  end
  class SharedEventAttendance < ActiveRecord::Base
    has_paper_trail
    belongs_to :shared_event
    belongs_to :user
    has_many :shared_event_field_datas, dependent: :destroy, autosave: true, inverse_of: :shared_event_attendance
  end
  class SharedEventFieldData < ActiveRecord::Base
    has_paper_trail
    belongs_to :shared_event_field
    belongs_to :shared_event_attendance
  end

  def up
    [SharedEvent, SharedEventAttendance, SharedEventField, SharedEventFieldData].each do |model|
      model.delete_all
    end
    
    %w{ shared_event_attendances shared_event_field_data shared_event_fields shared_events }.each do |table|
      drop_table table if ActiveRecord::Base.connection.table_exists?(table)
    end
  end

  def down
    create_table "shared_event_attendances", force: true do |t|
      t.integer  "shared_event_id", null: false
      t.integer  "user_id",         null: false
      t.integer  "section_id",      null: false
      t.integer  "event_id",        null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

    add_index "shared_event_attendances", ["shared_event_id"], name: "index_shared_event_attendances_on_shared_event_id"
    add_index "shared_event_attendances", ["user_id"], name: "index_shared_event_attendances_on_user_id"

    create_table "shared_event_field_data", force: true do |t|
      t.integer  "shared_event_field_id",      null: false
      t.integer  "shared_event_attendance_id", null: false
      t.string   "source_type",                null: false
      t.integer  "source_id"
      t.string   "source_field",               null: false
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
    end

    add_index "shared_event_field_data", ["shared_event_attendance_id"], name: "index_shared_event_field_data_on_shared_event_attendance_id"
    add_index "shared_event_field_data", ["shared_event_field_id"], name: "index_shared_event_field_data_on_shared_event_field_id"

    create_table "shared_event_fields", force: true do |t|
      t.integer  "shared_event_id", null: false
      t.string   "name",            null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

    add_index "shared_event_fields", ["shared_event_id"], name: "index_shared_event_fields_on_shared_event_id"

    create_table "shared_events", force: true do |t|
      t.string   "name",            null: false
      t.date     "start_date"
      t.string   "start_time"
      t.date     "finish_date"
      t.string   "finish_time"
      t.string   "cost"
      t.string   "location"
      t.text     "notes"
      t.integer  "user_id",         null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
      t.date     "confirm_by_date"
    end

    add_index "shared_events", ["user_id"], name: "index_shared_events_on_user_id"
  end

end
