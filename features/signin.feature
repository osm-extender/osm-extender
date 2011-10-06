Feature: Sign in
    As a user of the site
    In order to use the site
    I want to be able to sign in to my account

    Scenario: Signin
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page

    Scenario: Signin (differing email case)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "ALICE@example.com" with password "P@55word"
        Then I should see "Sucessfully signed in."
	And I should be on the my_page page

    Scenario: Signin (with redirect)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
	And I am on the my_account page
        When I fill in "Email address" with "alice@example.com"
	And I fill in "Password" with "P@55word"
	And I press "Sign in"
        Then I should see "Sucessfully signed in."
	And I should be on the my_account page

    Scenario: Signin (bad password)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "wrong"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (bad email address)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "wr@ng.com" with password "P@55word"
        Then I should see "Email address or password was invalid."
	And I should be on the sessions page

    Scenario: Signin (not activated)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "You have not yet activated your account."
	And I should be on the sessions page
