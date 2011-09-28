FactoryGirl.define do
  factory :user do
    sequence(:email_address) { |n| "someone-#{n}@example.com" }
    password 'abCD56&*'
    password_confirmation { |u| u.password }
    name 'Someone'
  end
end
