class NotifierMailerPreview < ActionMailer::Preview
#  before_action { load 'config/environments/development.rb' }

  def contact_form_submission
    contact = ContactUs.new(
      name: 'John Smith',
      email_address: 'john.smith@example.com',
      message: Faker::Lorem.paragraph(rand(1..11))
    )
    NotifierMailer.contact_form_submission(contact)
  end

  def email_list_changed
    list = EmailList.new(
      id: 0,
      name: 'TEST LIST',
      user: User.new(
        name: 'John Smith',
        email_address: 'john.smith@example.com'
      )
    )
    list.section = Osm::Section.new(id: 0, name: 'SECTION', group_name: 'GROUP')
    NotifierMailer.email_list_changed(list)
  end

  def email_list_changed__no_current_term
    exception = Osm::Error::NoCurrentTerm.new('There is no current term for the section.', 0)
    list = EmailList.new(
      id: 0,
      name: 'TEST LIST',
      user: User.new( 
        name: 'John Smith',
        email_address: 'john.smith@example.com'
      )
    )
    list.section = Osm::Section.new(id: 0, name: 'SECTION', group_name: 'GROUP')
    NotifierMailer.email_list_changed__no_current_term(list, exception)
  end

  def reminder_failed
    reminder = EmailReminder.new(id: 0)
    NotifierMailer.reminder_failed(reminder, get_an_exception)
  end

  def rake_exception
    NotifierMailer.rake_exception('TASK NAME', get_an_exception)
  end


  private
  def get_an_exception(message = 'AN EXCEPTION')
    exception = nil
    begin
      raise Exception.new(message)
    rescue Exception => e
      exception = e
    end
    exception
  end

end
