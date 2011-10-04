Feature: Sign in
    As a user of the site
    In order to use the site
    I want to be able to sign in to my account

    Scenario: Signin
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
        When I signin as "alice@example.com" with password "Alice%12"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page

    Scenario: Signin (differing email case)
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
        When I signin as "ALICE@example.com" with password "Alice%12"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page

    Scenario: Signin (with redirect)
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
	And I am on the my_account page
        When I fill in "Email address" with "alice@example.com"
	And I fill in "Password" with "Alice%12"
	And I press "Sign in"
        Then I should see "Sucessfully signed in."
	And I should be on the my_account page

    Scenario: Signin (bad password)
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
        When I signin as "alice@example.com" with password "wrong"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (bad email address)
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
        When I signin as "wr@ng.com" with password "Alice%12"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (not activated)
        Given I have the following user records
	    | email_address     | password |
	    | alice@example.com | Alice%12 |
        When I signin as "alice@example.com" with password "Alice%12"
        Then I should see "You have not yet activated your account."
	And I should be on the sessions page
