FactoryGirl.define do
  factory :user do
    sequence(:email_address) { |n| "someone-#{n}@example.com" }
    password 'P@55word'
    password_confirmation { |u| u.password }
    name { |u| u.email_address.match(/[^@]*/)[0].capitalize } # Take before the @
  end

  factory :announcement do
    sequence(:message) { |n| "Message #{n}" }
    start Time.now
    finish 1.week.from_now
  end

  factory :shared_event do
    ignore do
      user_email_address 'alice@example.com'
    end

    sequence(:name) { |n| "Shared event #{n}" }
    start_date 1.week.from_now
    confirm_by_date 1.day.from_now
    user_id { User.find_by_email_address(user_email_address).id }
    cost 1.23
  end

end
