class Faq < ActiveRecord::Base
  attr_accessible :question, :answer, :active, :tag_tokens
  attr_reader :tag_tokens

  has_many :tagings, :class_name => :FaqTaging, :dependent => :destroy, :inverse_of => :tag
  has_many :tags, :class_name => :FaqTag, :source => :tag, :through => :tagings

  validates_presence_of :question
  validates_uniqueness_of :question

  validates_presence_of :answer

  validate :ensure_at_least_one_tag

  def tag_tokens=(tokens)
    self.tag_ids = FaqTag.ids_from_tags(tokens)
  end


  private
  def ensure_at_least_one_tag
    errors.add(:base, "Must have at least one tag") unless tags.size > 0
  end

end
