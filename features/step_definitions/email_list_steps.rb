Given /^"([^"]*)" has a saved email list "([^"]*)" for section "(\d*)"$/ do |email, name, section|
  user = User.find_by_email_address(email)
  user.email_lists.create({
    :name => name,
    :section_id => section.to_i,
    :email1 => true,
    :email2 => true,
    :email3 => true,
    :email4 => true,
    :match_type => true,
    :match_grouping => 0
  })
end
