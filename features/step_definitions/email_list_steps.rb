Given /^"([^"]*)" has a saved email list "([^"]*)" for section "(\d*)"$/ do |email, name, section|
  user = User.find_by_email_address(email)
  user.email_lists.create({
    :name => name,
    :section_id => section.to_i,
    :contact_member => 3,
    :contact_primary => 3,
    :contact_secondary => 3,
    :contact_emergency => 3,
    :match_type => true,
    :match_grouping => 0,
    :notify_changed => true,
  })
end
