Then /^debug emails$/ do
  puts ActionMailer::Base.deliveries.join("\n")
end
