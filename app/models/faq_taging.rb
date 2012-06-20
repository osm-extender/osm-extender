class FaqTaging < ActiveRecord::Base
  attr_accessible :faq_id, :faq_tag_id

  belongs_to :faq_tag
  belongs_to :faq

  validates_presence_of :faq_tag
  validates_presence_of :faq

end
