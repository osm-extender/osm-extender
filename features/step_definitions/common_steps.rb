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

When /^(.*) in the "([^\"]*)" form$/ do |action, form_id|
  within :xpath, "//form[@id=\"#{form_id}\"]" do
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

Then /^(?:in )?the "([^\"]*)" column of the row with id "([^\"]*)" (.*)$/ do |column_title, row_id, action|
  col_number = 4
  all(:xpath, "//*[(th|td)/descendant-or-self::*[contains(text(), '#{column_title}')]]/th").each do |element|
    col_number += 1
    break if element.has_content?(column_title)
  end
  within :xpath, "//tr[@id=\"#{row_id}\"]/td[#{col_number}]" do
    step action
  end
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

Then /^"([^"]*)" should be selected for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then /^"([^"]*)" should( not)? be an option for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, negate, field, selector|
  with_scope(selector) do
    expectation = negate ? :should_not : :should
    field_labeled(field).first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
  end
end

Then /^I should get a download with filename "([^\"]*)"(?: and MIME type "([^\"]*)")?$/ do |filename, mime_type|
  # Taken and adapted from: https://makandracards.com/makandra/931-test-a-download-s-filename-with-cucumber
  page.driver.response.headers['Content-Disposition'].should == "attachment; filename=\"#{filename}\""
  if mime_type
    page.driver.response.headers['Content-Type'].should == mime_type
  end
end

Then /^the body should contain "(.*)"$/ do |body|
  page.driver.response.body.should include(body)
end

Then /^the body should not contain "(.*)"$/ do |body|
  page.driver.response.body.should_not include(body)
end

Then /^show me the body$/ do
  puts page.driver.response.body
end
