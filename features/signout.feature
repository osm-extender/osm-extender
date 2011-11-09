@signout
@user
@session

Feature: Sign out
    As a user of the site
    In order to stop other people acting as me
    I want to sign out of my account


    Scenario: Signout
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "alice%12"
        And I go to the signout page
        Then I should see "Sucessfully signed out."
        And I should be on the root page

    Scenario: Signout (not signed in)
        When I go to the signout page
        Then I should see "Sucessfully signed out."
        And I should be on the root page
