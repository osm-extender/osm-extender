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

Given /^I have no users$/ do
  User.delete_all
end

When /^I signin as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  visit signin_url
  fill_in 'Email address', :with => email
  fill_in 'Password', :with => password
  click_button 'Sign in'
end

When /^"([^"]*)" is an activated user account$/ do |email|
    user = User.find_by_email_address(email)
    user.activate!
end

Then /^I should have (\d+) users?$/ do |count|
  User.count.should == count.to_i
end
