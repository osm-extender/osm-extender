class FaqTaging < ActiveRecord::Base
  attr_accessible :faq, :tag, :position

  belongs_to :tag, :class_name => 'FaqTag', :foreign_key => :tag_id
  belongs_to :faq, :foreign_key => :faq_id

  validates_presence_of :tag
  validates_presence_of :faq

  validates_uniqueness_of :faq_id, :scope => :tag_id

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  acts_as_list
  
  after_destroy :delete_tag_if_unused


  def delete_tag_if_unused
    tag.destroy if tag.faqs.size == 0
    return true
  end

end
