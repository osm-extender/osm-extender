class SharedEventAttendance < ActiveRecord::Base
  audited :associated_with => :shared_event
  has_associated_audits

  belongs_to :shared_event
  belongs_to :user
  has_many :shared_event_field_datas, :dependent => :destroy, :autosave => true

  attr_accessible :section_id, :event_id

  validates_presence_of :user
  validates_presence_of :shared_event
  validates_numericality_of :section_id, :only_integer=>true, :greater_than=>0
  validates_numericality_of :event_id, :only_integer=>true, :greater_than=>0
  validates_uniqueness_of :shared_event_id, :scope => [:user_id, :section_id]
  validate :all_fields_have_data, :if => Proc.new { |record| record .persisted? }


  def get_attendees_data
    data = []
    section = Osm::Section.get(user.osm_api, section_id)
    event = Osm::Event.get(user.osm_api, section, event_id)
    attendance = event.get_attendance(user.osm_api)
    members = nil
    flexi_record_datas = {}
    attendance.each do |attend|
      if attend.attending == :yes
        this_data = {
          :first_name => attend.first_name,
          :last_name => attend.last_name,
          :adult => ((attend.grouping_id == -2) || section.adults?),
        }
        shared_event_field_datas.each do |field|
          if field.source_type.to_sym == :event
            this_data[field.shared_event_field.id] = attend.fields[field.source_field[2..-1].to_i]
          end
          if field.source_type.to_sym == :contact_details
            members ||= Osm::Member.get_for_section(user.osm_api, section_id).inject({}) { |hash, member| hash[member.id] = member; hash}
            this_data[field.shared_event_field.id] = members[attend.member_id] ? members[attend.member_id].send(field.source_field) : ''
          end
          if field.source_type.to_sym == :flexi_record
            record = nil
            unless section.nil?
              section.flexi_records.each do |r|
                if r.id == field.source_id
                  record = r
                  break
                end
              end
            end
            unless record.nil?
              flexi_record_datas[field.source_id] ||= record.get_data(user.osm_api).inject({}){ |hash, d| hash[d.member_id] = d; hash}
              this_data[field.shared_event_field.id] = flexi_record_datas[field.source_id][attend.member_id] ? flexi_record_datas[field.source_id][attend.member_id].fields[field.source_field] : ''
            end
          end
        end
        data.push this_data
      end
    end
    return data
  end


  private
  def all_fields_have_data
    shared_event.fields.each do |field|
      seen = false
      shared_event_field_datas.each do |data|
        seen = true if data.shared_event_field == field
      end
      unless seen
        errors.add(:shared_event_field_datas, "Has nothing for #{field.name} (id:#{field.id})")
      end
    end
  end

end
