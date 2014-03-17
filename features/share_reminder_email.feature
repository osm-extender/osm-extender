@share_reminder_email
@email_reminder
@email_reminder_item
@reminder_mailer
@osm

Feature: Reminder Email
    As a section leader
    In order to allow techno-phobic fellow leaders to keep on top of what's happening with my section
    I want to be able to share my reminder emails
    As a sectiion leader who has an email shared with me
    In order to protect my inbox
    I want to be able to control which shared reminders I receive

    Background:
	Given I have no users
        And I have the following user records
	    | email_address       |
	    | alice@example.com   |
	    | bob@example.com     |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
        And "bob@example.com" is an activated user account
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	And an OSM request to get the notepad for section 1 will give "This is a test notepad message."
	And "alice@example.com" has a reminder email for section 1 on "Tuesday"
        And "alice@example.com" has a notepad item in her "Tuesday" email reminder for section 1
	And no emails have been sent


    @send_email
    Scenario: Share reminder with someone who doesn't use OSMX
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Sharing]" in the "Actions" column of the "Tuesday" row
        And I fill in "email_reminder_share_name" with "Charlie"
        And I fill in "email_reminder_share_email_address" with "charlie@example.com"
        And I press "Add new person"
        Then I should see "Email reminder was successfully shared"
        And "charlie@example.com" should receive 1 email with subject "A Reminder Email for Section 1 (1st Somewhere) was Shared With You"

        When I open the email with subject /Shared With You/
        And I click the /email_reminder_subscriptions/ link in the email
        And I fill in "email_reminder_subscription_name" with "Charlie2"
        And I fill in "email_reminder_subscription_email_address" with "charlie2@example.com"
	And I select "subscribed" from "state"
        And I press "Update subscription"
        Then I should see "Your subscription was updated"
	And "charlie2@example.com" should receive 1 email with subject "Subscribed to reminder for Section 1 (1st Somewhere) on Tuesday"

    @send_email
    Scenario: Share reminder with someone who uses OSMX
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Sharing]" in the "Actions" column of the "Tuesday" row
        And I fill in "email_reminder_share_name" with "Bob"
        And I fill in "email_reminder_share_email_address" with "bob@example.com"
        And I press "Add new person"
        Then I should see "Email reminder was successfully shared"
        And "bob@example.com" should receive 1 email with subject "A Reminder Email for Section 1 (1st Somewhere) was Shared With You"

        When I signin as "bob@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Edit subscription]" in the "Actions" column of the "Tuesday" row
        And I fill in "email_reminder_subscription_name" with "Charlie2"
        And I fill in "email_reminder_subscription_email_address" with "charlie2@example.com"
	And I select "unsubscribed" from "state"
        And I press "Update subscription"
        Then I should see "Your subscription was updated"
	And "charlie2@example.com" should receive 1 email with subject "Unsubscribed from reminder for Section 1 (1st Somewhere) on Tuesday"


    @send_email
    Scenario: Resend invitation
        Given "alice@example.com" has shared her "Tuesday" email reminder with "charlie@example.com" and it is in the pending state
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Sharing]" in the "Actions" column of the "Tuesday" row
        And I follow "[Resend notification]" in the "Actions" column of the "charlie@example.com" row
        Then I should see "Invitation was successfully resent"
        And "charlie@example.com" should receive 1 email with subject "A Reminder Email for Section 1 (1st Somewhere) was Shared With You"

    Scenario: No option to resend invitation unless share is pending
        Given "alice@example.com" has shared her "Tuesday" email reminder with "charlie@example.com" and it is in the subscribed state
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Sharing]" in the "Actions" column of the "Tuesday" row
        Then I should not see "[Resend notification]" in the "Actions" column of the "charlie@example.com" row


    Scenario: Sharee can also see the config of the reminder
        Given "alice@example.com" has shared her "Tuesday" email reminder with "bob@example.com" and it is in the pending state
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Show]" in the "Actions" column of the "Tuesday" row
        Then I should see "Reminder details"

    Scenario: Sharee can also preview the reminder
        Given "alice@example.com" has shared her "Tuesday" email reminder with "bob@example.com" and it is in the pending state
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Preview]" in the "Actions" column of the "Tuesday" row
        Then I should see "This is your reminder email for Section 1 (1st Somewhere)"

    @send_email
    Scenario: Sharee can also send the reminder
        Given "alice@example.com" has shared her "Tuesday" email reminder with "bob@example.com" and it is in the pending state
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Send]" in the "Actions" column of the "Tuesday" row
	Then I should see "Email reminder was successfully sent"
	And "bob@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"
	And "alice@example.com" should receive 0 email with subject "Reminder Email for Section 1 (1st Somewhere)"

    @send_email
    Scenario: When sharer sends the email only they get it
        Given "alice@example.com" has shared her "Tuesday" email reminder with "bob@example.com" and it is in the subscribed state
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of email_reminders
        And I follow "[Send]" in the "Actions" column of the "Tuesday" row
	Then I should see "Email reminder was successfully sent"
	And "alice@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"
	And "bob@example.com" should receive 0 email with subject "Reminder Email for Section 1 (1st Somewhere)"

    @send_email
    Scenario: When the email is sent everyone gets it
        Given "alice@example.com" has shared her "Tuesday" email reminder with "bob@example.com" and it is in the subscribed state
	When "alice@example.com"'s reminder email for section 1 on "Tuesday" is sent
	Then "alice@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"
	Then "bob@example.com" should receive 1 email with subject "Reminder Email for Section 1 (1st Somewhere)"



    Scenario: Other people can not see the config of the reminder
        Given "alice@example.com" has shared her "Tuesday" email reminder with "charlie@example.com" and it is in the pending state
        When I signin as "bob@example.com" with password "P@55word"
        And I go to show "alice@example.com"'s email reminder
        Then I should see "You are not authorised to do that"

    Scenario: Other people can not preview the reminder
        Given "alice@example.com" has shared her "Tuesday" email reminder with "charlie@example.com" and it is in the pending state
        When I signin as "bob@example.com" with password "P@55word"
        And I go to preview "alice@example.com"'s email reminder
        Then I should see "You are not authorised to do that"
