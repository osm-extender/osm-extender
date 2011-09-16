require 'yaml'

# Class to intercept mails being sent and send them to another address for testing purposes.
class DevelopmentMailInterceptor

  # When a message is being sent:
  # * Prepend an array of receipents to the subject
  # * Deliver it to a specified developer instead
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = YAML.load(IO.read(File.join(Rails.root, 'config', 'machine.yml')))['development_mail_interceptor_send_to']
  end

end
