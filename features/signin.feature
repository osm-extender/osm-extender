@signin
@user
@user_mailer

Feature: Sign in
    As a user of the site
    In order to use the site
    I want to be able to sign in to my account


    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account


    Scenario: Signin
	When I go to the root page
	Then I should see "Sign in"
	And I should see "Sign up"
	And I should not see "My account"
	And I should not see "My page"
	And I should not see "Sign out"
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page
	And I should see "My account"
	And I should see "My page"
	And I should see "Sign out"
	And I should not see "Sign in"
	And I should not see "Sign up"
	And "alice@example.com" should receive no email with subject /Account Locked/

    Scenario: Signin (differing email case)
        When I signin as "ALICE@example.com" with password "P@55word"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page

    Scenario: Signin (with redirect)
	Given I am on the my_account page
        When I fill in "Email address" with "alice@example.com"
	And I fill in "Password" with "P@55word"
	And I press "Sign in"
        Then I should see "Sucessfully signed in."
	And I should be on the my_account page

    Scenario: Signin (bad password)
        When I signin as "alice@example.com" with password "wrong"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (bad email address)
        When I signin as "wr@ng.com" with password "P@55word"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (not activated)
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "You have not yet activated your account."
	And I should be on the sessions page

@focus
    @send_email
    Scenario: User should be locked after 3 bad logins
        When I signin as "alice@example.com" with password "wrong"
        Then I should see "Email address or password was invalid."
        When I signin as "alice@example.com" with password "wrong"
        Then I should see "Email address or password was invalid."
        When I signin as "alice@example.com" with password "wrong"
        Then "alice@example.com" should be a locked user account
	And I should see "The account was locked."
	And "alice@example.com" should receive an email with subject /Account Locked/

    Scenario: User should be unlocked after timeout
	Given "alice@example.com" has been a locked user account
        When I signin as "alice@example.com" with password "P@55word"
        Then "alice@example.com" should not be a locked user account
	And I should see "Sucessfully signed in."
