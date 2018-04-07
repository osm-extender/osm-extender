FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "someone-#{n}@example.com" }
    password 'P@55word'
    password_confirmation { |u| u.password }
    name { |u| u.email_address.match(/[^@]*/)[0].capitalize } # Take before the @
    gdpr_consent_at { Time.now.utc }

    factory :user_connected_to_osm do
      osm_userid 100
      osm_secret 200
    end
  end

  factory :announcement do
    sequence(:message) { |n| "Message #{n}" }
    start Time.now
    finish 1.week.from_now
  end

  factory :shared_event do
    transient do
      user_email_address 'alice@example.com'
    end

    sequence(:name) { |n| "Shared event #{n}" }
    start_date 1.week.from_now
    confirm_by_date 1.day.from_now
    user_id { User.find_by_email_address(user_email_address).id }
    cost 1.23
  end

  factory :automation_task do
    user { create :user_connected_to_osm }
    section_id 123
    section_name 'Unknown'
    type 'AutomationTaskTestItem'
    configuration { Hash.new }
  end

end
