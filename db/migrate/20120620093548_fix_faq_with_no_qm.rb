class FixFaqWithNoQm < ActiveRecord::Migration

  def up
    unless Rails.env.test?
      faq = Faq.find_by_question("What's Online Scout Manager Extender")
      faq.question = "What's Online Scout Manager Extender?"
      faq.save
    end
  end


  def down
    unless Rails.env.test?
      faq = Faq.find_by_question("What's Online Scout Manager Extender?")
      faq.question = "What's Online Scout Manager Extender"
      faq.save
    end
  end
end
