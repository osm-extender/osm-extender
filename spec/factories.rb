FactoryGirl.define do
  factory :user do
    sequence(:email_address) { |n| "someone-#{n}@example.com" }
    password 'P@55word'
    password_confirmation { |u| u.password }
    name 'Someone'
  end
end
