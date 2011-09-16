require 'test_helper'
require 'yaml'
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
# * Replace the to address with 'robert@robertgauld.co.uk'
class DevelopmentMailInterceptorTest < ActiveSupport::TestCase

  test "makes required changes" do
    expected_to = YAML.load(IO.read(File.join(Rails.root, 'config', 'machine.yml')))['development_mail_interceptor_send_to']
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
