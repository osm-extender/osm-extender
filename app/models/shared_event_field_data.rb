class SharedEventFieldData < ActiveRecord::Base
  has_paper_trail

  belongs_to :shared_event_field
  belongs_to :shared_event_attendance

  validates_presence_of :shared_event_field
  validates_presence_of :shared_event_attendance, :if => Proc.new { |record| record .persisted? }
  validates :source_type, :inclusion => {:in => [:contact_details, :flexi_record, :event]}
  validates :source_field, :inclusion => {:in => [:age, :date_of_birth, :started, :joining_in_years, :joined, :joined_years, :phone1, :phone2, :phone3, :phone4, :address, :address2, :email1, :email2, :email3, :email4, :subs, :medical, :ethnicity, :religion, :school, :parents, :notes, :custom1, :custom2, :custom3, :custom4, :custom5, :custom6, :custom7, :custom8, :custom9]}, :if => Proc.new { |record| record.source_type == :contact_details }
  validates_presence_of :source_id, :unless => Proc.new { |record| [:contact_details, :event].include?(record.source_type) }
  validates_presence_of :source_field
end
