class SharedEvent < ActiveRecord::Base
  belongs_to :user
  has_many :attendance, :dependent => :destroy, :class_name => SharedEventAttendance
  has_many :fields, :dependent => :destroy, :class_name => SharedEventField

  attr_accessible :cost, :finish_date, :finish_time, :name, :notes, :location, :start_date, :start_time

  validates_presence_of :user
  validates_presence_of :name
  validates :start_time, :time_24h_format => {:allow_blank => true}
  validates :finish_time, :time_24h_format => {:allow_blank => true}
  validates :start_date, :date_format => true
  validates :finish_date, :date_format => {:allow_blank => true}


  def get_attendees_data
    data = {}
    attendance.each do |att|
      section_data = []
      att.get_attendees_data.each do |att_data|
        section_data.push(att_data)
      end
      section = Osm::Section.get(att.user.osm_api, att.section_id)
      data["#{section.name} (#{section.group_name})"] = section_data
    end
    return data
  end


  def start
    Osm::make_datetime(start_date.strftime('%Y-%m-%d'), start_time)
  end
  def finish
    finish_date? ? Osm::make_datetime(finish_date.strftime('%Y-%m-%d'), finish_time) : nil
  end

end
