class UpdateFaqForEmailList < ActiveRecord::Migration

  def self.up
    faq = Faq.find_by_question("What's the Email lists feature?")
    faq.answer = "The Email lists feature allows you to create a list of email addresses (which you can then copy-paste into your email). You can select which of the four email fields in OSM to include and some basic selection criteria.\n\nSimply tick off the email fields you'd like to get the email addresses from and use the drop down boxes to choose which email addresses to get. For example \"for members who are not in the leaders\" would give you all youth members.\n\nAfter retreiving the list of email addresses you'll be able to save the list for future reuse. Saving the list saves the criteria used for generating it, not the actual email addresses."
    faq.save!
  end

  def self.down
    faq = Faq.find_by_question("What's the Email lists feature?")
    faq.answer = "The Email lists feature allows you to create a list of email addresses (which you can then copy-paste into your email). You can select which of the four email fields in OSM to include and some basic selection criteria.\n\nSimply tick off the email fields you'd like to get the email addresses from and use the drop down boxes to choose which email addresses to get. For example \"for members who are not in the leaders\" would give you all youth members."
    faq.save!
  end

end
