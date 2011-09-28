Given /^I have the following (.+) records?$/ do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end
end

Given /^"([^"]*)" has password_reset_token "([^"]*)"$/ do |email, reset_token|
  user = User.find_by_email_address(email)
  user.reset_password_token = reset_token
  user.reset_password_token_expires_at = Time.now + 10.minutes
  user.save!
end

Given /^"([^"]*)" has activate_account_token "([^"]*)"$/ do |email, activation_token|
  user = User.find_by_email_address(email)
  user.activation_token = activation_token
  user.activation_token_expires_at = Time.now + 10.minutes
  user.save!
end

Given /^I have no users$/ do
  User.delete_all
end

When /^I signin as "([^"]*)" with password "([^"]*)"$/ do |username, password|
  visit signin_url
  fill_in 'Email address', :with => username
  fill_in 'Password', :with => password
  click_button 'Sign in'
end

When /^"([^"]*)" is an activated account$/ do |email|
    user = User.find_by_email_address(email)
    user.activate!
end

Then /^I should have (\d+) users?$/ do |count|
  User.count.should == count.to_i
end