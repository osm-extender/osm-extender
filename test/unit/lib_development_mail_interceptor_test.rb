require 'test_helper'
require File.join(Rails.root, 'lib', 'development_mail_interceptor')


# Helper class to take the role of a message:
# * Stores to address and subject
class MailInterceptorTester
  attr_accessor :to, :subject
  def initialize(options={})
    @to = options[:to]
    @subject = options[:subject]
  end
end


# Test the DevelopmentMailIntercepter, it should:
# * Prepend the addresses the mail was sent to to the subject
# * Replace the to address with the configured send to address.
class DevelopmentMailInterceptorTest < ActiveSupport::TestCase

  test "makes required changes" do
    expected_to = Settings.read('Mail Server - Development recipient')
    to = ['to_address@example.com']
    expected_to_in_subject = '"to_address@example.com"'
    subject = 'This is the subject'

    mail = MailInterceptorTester.new :to=>to, :subject=>subject
    assert_not_nil mail, 'Got a nil MailIntercepterTester'
    DevelopmentMailInterceptor.delivering_email(mail)
    assert_equal expected_to, mail.to, 'To address was not changed'
    assert_equal "[#{expected_to_in_subject}] #{subject}", mail.subject, 'Subject was not correctly changed'
  end

end
