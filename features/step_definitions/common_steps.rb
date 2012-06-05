Given /^I have the following (.+) records?$/ do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end
end

Given /^I have no (.+)(?:s| records)$/ do |model_name|
  Kernel.const_get(model_name.gsub(' ', '_').camelize).delete_all
end

Given /^time is frozen$/ do
  Timecop.freeze Time.now.utc
end


When /^(.*) in the "([^\"]*)" column of the "([^\"]*)" row$/ do |action, column_title, row_title|
  col_number = 0
  all(:xpath, "//*[(th|td)/descendant-or-self::*[contains(text(), '#{column_title}')]]/th").each do |element|
    col_number += 1
    break if element.has_content?(column_title)
  end
  within :xpath, "//*[(th|td)/descendant-or-self::*[contains(text(), '#{row_title}')]]/td[#{col_number}]" do
    step action
  end
end

When /^(?:|I )post to (.+)$/ do |page_name|
  page.driver.post(path_to(page_name), { :params => {} })
  5.times do
    page.driver.get(page.driver.response["Location"], {}, { "HTTP_REFERER" => page.driver.request.url })  if page.driver.response.redirect?
  end
  raise Capybara::InfiniteRedirectError, "redirected more than 5 times, check for infinite redirects." if page.driver.response.redirect?
end


Then /^I should have (\d+) (.+)(?:s| records)$/ do |count, model_name|
  Kernel.const_get(model_name.gsub(' ', '_').camelize).count.should == count.to_i
end

Then /^the "([^\"]*)" column of the "([^\"]*)" row (.*)$/ do |column_title, row_title, action|
  col_number = 0
  all(:xpath, "//*[(th|td)/descendant-or-self::*[contains(text(), '#{column_title}')]]/th").each do |element|
    col_number += 1
    break if element.has_content?(column_title)
  end
  within :xpath, "//*[(th|td)/descendant-or-self::*[contains(text(), '#{row_title}')]]/td[#{col_number}]" do
    step action
  end
end

Then /^"([^"]*)" should contain "([^"]*)"$/ do |field, value|
  field = find_field(field)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  if field_value.respond_to? :should
    field_value.should =~ /#{value}/
  else
    assert_match(/#{value}/, field_value)
  end
end

Then /^"([^"]*)" should not contain "([^"]*)"$/ do |field, value|
  field = find_field(field)
  field_value = (field.tag_name == 'textarea') ? field.text : field.value
  if field_value.respond_to? :should_not
    field_value.should_not =~ /#{value}/
  else
    assert_no_match(/#{value}/, field_value)
  end
end
