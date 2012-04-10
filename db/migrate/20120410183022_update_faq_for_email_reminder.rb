class UpdateFaqForEmailReminder < ActiveRecord::Migration

  def self.up
    faq = Faq.find_by_question("What's the Email reminder feature?")
    faq.answer = "The email reminder feature is designed to send you a weekly email of things you should be aware of, it is customisable - you get to choose what items appear and how far back/forwrd they look. In order to get started follow the links into the Email reminders area and to create a new reminder. Once you have created your reminder you'll need to add some items to it (otherwise you'll get a blank email each week). The availible items are:\n\n* Birthdays - Members of your section who have either just had or are about to have a birthday, you can customise from how far in the past to how far in the future birthdays are shown for.\n* Badges due - Displays a list of what badges each member is due.\n* Programme - Lists the programme (and activities) for the next few weeks, you can customise how many weeks ahead it looks.\n* Events - Lists the events coming up in the next few months, you can customise how many months ahead it looks.\n* Members not seen - Displays the members who have not been marked present for the last few weeks, you can customise how many weeks behind it looks.\n* Section notepad - Displays the contents of OSM's notepad for the section."
    faq.save!
  end

  def self.down
    faq = Faq.find_by_question("What's the Email reminder feature?")
    faq.answer = "The email reminder feature is designed to send you a weekly email of things you should be aware of, it is customisable - you get to choose what items appear and how far back/forwrd they look. In order to get started follow the links into the Email reminders area and to create a new reminder. Once you have created your reminder you'll need to add some items to it (otherwise you'll get a blank email each week). The availible items are:\n\n* Birthdays - Members of your section who have either just had or are about to have a birthday, you can customise from how far in the past to how far in the future birthdays are shown for.\n* Badges due - Displays a list of what badges each member is due.\n* Programme - Lists the programme (and activities) for the next few weeks, you can customise how many weeks ahead it looks.\n* Events - Lists the events coming up in the next few months, you can customise how many months ahead it looks.\n* Members not seen - Displays the members sho have not been marked present for the last few weeks, you can customise how many weeks behind it looks."
    faq.save!
  end

end
