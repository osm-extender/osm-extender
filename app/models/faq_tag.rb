class FaqTag < ActiveRecord::Base
  attr_accessible :name

  has_many :faq_tagings, :dependent => :destroy
  has_many :faqs, :through => :faq_tagings
  has_many :active_faqs, :class_name => 'Faq', :source => :faq, :through => :faq_tagings, :conditions => ['active = ?', true]

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.tokens(query)
    tags = where("name like ?", "%#{query}%")
    create_tag = {id: "<<<#{query}>>>", name: "Create: \"#{query}\""}
    tags.push create_tag if where("name like ?", "#{query}").size == 0
    return tags.empty? ? [create_tag] : tags
  end
  
  def self.ids_from_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
    tokens.split(',')
  end

end
