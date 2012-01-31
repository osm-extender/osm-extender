@contact_us

Feature: My Account
    As a user of the site
    I want to be able to contact the people who run it

    Scenario: Send message
        When I go to the root page
        And I follow "Contact us"
        Then I should be on the new contact u page
        When I fill in "Name" with "A User"
        And I fill in "Email address" with "someuser@example.com"
        And I fill in "Message" with "Some text"
        And I press "Send"
        Then I should be on the root page
        And I should see "Your message was sent"
        And "contactus@example.com" should have 1 email

    Scenario: Logged in user should see their name and email address but no captcha
        Given I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the new contact u page
        Then "Email address" should contain "alice@example.com"
        And "Name" should contain "Alice"

    Scenario: Send message (missing name)
        When I go to the new contact u page
        And I fill in "Email address" with "someuser@example.com"
        And I fill in "Message" with "Some text"
        And I press "Send"
        Then I should see "Name can't be blank"
        And I should not see "Your message was sent"
        And there should be no emails

    Scenario: Send message (missing email address)
        When I go to the new contact u page
        And I fill in "Name" with "A User"
        And I fill in "Message" with "Some text"
        And I press "Send"
        Then I should see "Email address can't be blank"
        And I should not see "Your message was sent"
        And there should be no emails

    Scenario: Send message (missing message)
        When I go to the new contact u page
        And I fill in "Name" with "A User"
        And I fill in "Email address" with "someuser@example.com"
        And I press "Send"
        Then I should see "Message can't be blank"
        And I should not see "Your message was sent"
        And there should be no emails

    Scenario: Send message (bad email address)
        When I go to the new contact u page
        And I fill in "Name" with "A User"
        And I fill in "Email address" with "s"
        And I fill in "Message" with "Some text"
        And I press "Send"
        Then I should see "Email address does not look like an email address"
        And I should not see "Your message was sent"
        And there should be no emails