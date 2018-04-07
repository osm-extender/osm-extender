# Override handling of click_first_link_in_email to remove host name
module EmailHelpers
  def click_first_link_in_email(email = current_email)
    link = links_in_email(email).first
    visit '/' + link.match(/^(?:https?:\/\/[^\/]+)?\/(.+)$/)[1]
  end
end


Given /^"([^"]*)" has password_reset_token "([^"]*)"$/ do |email, reset_token|
  user = User.find_by_email_address(email)
  user.reset_password_token = reset_token
  user.reset_password_token_expires_at = Time.now + 10.minutes
  user.save!
end

Given /^"([^"]*)" has activation_token "([^"]*)"$/ do |email, activation_token|
  user = User.find_by_email_address(email)
  user.activation_token = activation_token
  user.activation_token_expires_at = Time.now + 10.minutes
  user.activation_state = :pending
  user.save!
end

Given /^"([^"]*)" has (\d*) failed login attempts$/ do |email, attempts|
  user = User.find_by_email_address(email)
  user.failed_logins_count = attempts.to_i
  user.save!
end

Given /^"([^"]*)" has been a locked user account$/ do |email|
  user = User.find_by_email_address(email)
  user.lock_expires_at = 1.hour.ago
  user.save!
end

Given /^"([^"]*)" is a locked user account$/ do |email|
    user = User.find_by_email_address(email)
    user.lock_expires_at = 1.hour.from_now
    user.save!
end

Given /^"([^"]*)" is an activated user account$/ do |email|
    user = User.find_by_email_address(email)
    user.activate!
end

Given /^"([^"]*)" can "([^"]*)"$/ do |email, permission|
  user = User.find_by_email_address(email)
  user.send('can_'+permission+'=', true)
  user.save
end

Given /^"([^"]*)" can not "([^"]*)"$/ do |email, permission|
  user = User.find_by_email_address(email)
  user.send('can_'+permission+'=', false)
  user.save
end



When /^I signin as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  visit signin_url
  fill_in 'Email address', :with => email
  fill_in 'Password', :with => password
  click_button 'Sign in'
end

When /^I signout$/ do
  visit signout_url
end



Then /^"([^"]*)" should be a locked user account$/ do |email|
    user = User.find_by_email_address(email)
    user.lock_expires_at.nil?.should == false
end

Then /^"([^"]*)" should not be a locked user account$/ do |email|
    user = User.find_by_email_address(email)
    user.lock_expires_at.nil?.should == true
end

Then /^user "([^"]*)" should have ([^"]*) "([^"]*)"$/ do |email, attribute, value|
  user = User.find_by_email_address(email)
  user.send(attribute).to_s.should == value
end

Then /^"([^"]*)" should be able to "([^"]*)"$/ do |email, permission|
  user = User.find_by_email_address(email)
  user.send('can_'+permission).should == true
end

Then /^"([^"]*)" should not be able to "([^"]*)"$/ do |email, permission|
  user = User.find_by_email_address(email)
  user.send('can_'+permission).should == false
end

Then /^"([^"]*)" should( not)? have a password reset token$/ do |email, negate|
  user = User.find_by_email_address(email)
  user.reset_password_token.nil?.should == (negate ? true : false)
end

Then /^"([^"]*)" should have a new activation deadline$/ do |email|
  user = User.find_by_email_address(email)
  expires_at = user.send(User.sorcery_config.activation_token_expires_at_attribute_name).utc
  should_expire_at = Time.now.utc + User.sorcery_config.activation_token_expiration_period
  expires_at.to_i.should == should_expire_at.to_i
end

Then /^"([^"]*)" should( not)? have granted GDPR consent$/ do |email, negate|
    user = User.find_by_email_address(email)
    user.gdpr_consent_at.nil?.should == (negate ? true : false)
end