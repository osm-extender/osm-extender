Given /^I have the following (.+) records?$/ do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end
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