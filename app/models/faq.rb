class Faq < ActiveRecord::Base
  validates_presence_of :question
  validates_uniqueness_of :question

  validates_presence_of :answer

end
