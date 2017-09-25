Given(/^there is no signup code$/) do
  ENV['signup_code'] = nil
end

Given(/^the signup code is (.+)$/) do |signup_code|
  ENV['signup_code'] = signup_code
end
