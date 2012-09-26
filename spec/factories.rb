FactoryGirl.define do
  factory :user do
    sequence(:email_address) { |n| "someone-#{n}@example.com" }
    password 'P@55word'
    password_confirmation { |u| u.password }
    name 'Someone'
  end

  factory :faq do
    sequence(:question) { |n| "FAQ #{n}" }
    sequence(:answer) { |n| "This is answer #{n}." }
    active true
    tag_tokens "1"
  end

  factory :announcement do
    sequence(:message) { |n| "Message #{n}" }
    start Time.now
    finish 1.week.from_now
  end

end
