Given /^there is no configuration for "([^"]*)"$/ do |key|
  val = SettingValue.find_by_key(key)
  val.delete unless val.nil?
  Settings.setup
end

Given /^the configuration for "([^"]*)" is "([^"]*)"$/ do |key, value|
  val = SettingValue.find_or_create_by_key(key)
  val.value = value
  val.save
  Settings.setup
end
