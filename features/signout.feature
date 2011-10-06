Feature: Sign out
    As a user of the site
    In order to stop other people acting as me
    I want to sign out of my account

    Scenario: Signout
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        When I signin as "alice@example.com" with password "alice%12"
        And I go to the signout page
        Then I should see "Sucessfully signed out."
        And I should be on the root page

    Scenario: Signout (not signed in)
        When I go to the signout page
        Then I should see "Sucessfully signed out."
        And I should be on the root page