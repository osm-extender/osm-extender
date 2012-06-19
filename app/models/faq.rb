class Faq < ActiveRecord::Base
  attr_accessible :question, :answer, :active

  validates_presence_of :question
  validates_uniqueness_of :question

  validates_presence_of :answer

end
