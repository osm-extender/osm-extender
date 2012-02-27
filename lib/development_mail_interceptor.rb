# Class to intercept mails being sent and send them to another address for testing purposes.
class DevelopmentMailInterceptor

  # When a message is being sent:
  # * Prepend an array of receipents to the subject
  # * Deliver it to a specified developer instead
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = Settings.read('Mail Server - Development recipient')
  end

end
