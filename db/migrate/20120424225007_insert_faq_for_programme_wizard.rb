class InsertFaqForProgrammeWizard < ActiveRecord::Migration

  def self.up
    Faq.create ({
      :question => "What's the Programme wizard feature?",
      :answer => "The programme wizard feature allows you create a number of evenings with a specified title and start/end times easily. You specify the start date, end date and how many days should be between each meeting, along with the meeting title, start time and end time - OSMX does the rest.",
      :active => true
    })
  end

  def self.down
    Faq.find_by_question("What's the Programme wizard feature?").delete
  end

end
