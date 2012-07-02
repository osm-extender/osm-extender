class FaqTag < ActiveRecord::Base
  attr_accessible :name, :position

  has_many :tagings, :class_name => :FaqTaging, :dependent => :destroy, :order => :position
  has_many :faqs, :through => :tagings, :order => :position

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_numericality_of :position, :only_integer=>true, :greater_than_or_equal_to=>0

  acts_as_list


  def active_faqs
    faqs.where('active = ?', true)
  end

  def self.all_by_tag(options={})
    faqs = {}
    order(:position).each do |tag|
      selected_faqs = options[:all_faqs] ? tag.faqs : tag.active_faqs
      faqs[tag] = selected_faqs unless selected_faqs.empty?
    end
    return faqs
  end

  def self.tags(query)
    tags = where("name like ?", "%#{query}%")
    create_tag = {id: "<<<#{query}>>>", name: "Create: \"#{query}\""}
    tags.push create_tag if where("name like ?", "#{query}").size == 0
    return tags.empty? ? [create_tag] : tags
  end
  
  def self.ids_from_tags(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
    tokens.split(',')
  end

end
