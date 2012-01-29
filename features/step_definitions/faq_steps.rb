Given /^I have no FAQs$/ do
  Faq.delete_all
end


Then /^I should have (\d+) FAQs?$/ do |count|
  Faq.count.should == count.to_i
end
