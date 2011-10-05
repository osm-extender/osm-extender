Feature: Forgotten Password
    As a user of the site
    In order to recover from forgetting my password
    I want to reset my password

    Scenario: Forgotten Password
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And I go to the signin page
        When I follow "Forgotten your password?"
        And I fill in "Email address" with "alice@example.com"
        And I press "Request password reset"
        Then I should see "Instructions have been sent to your email address."
	And I should be on the root page
        And "alice@example.com" should receive an email with subject /Password Reset/
        When I open the email with subject /Password Reset/
        And I click the first link in the email
        When I fill in "Password" with "P@55word"
        And I fill in "Password confirmation" with "P@55word"
        And I press "Reset password"
        Then I should see "Password sucessfully changed."
	And I should be on the root page


    Scenario: Forgotten Password (bad email address)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And I go to the signin page
        When I follow "Forgotten your password?"
        And I fill in "Email address" with "bob@example.com"
        And I press "Request password reset"
        Then I should see "Instructions have been sent to your email address."
	And I should be on the root page


    Scenario: Reset Password (bad token)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="123abc"
	And I should be on the root page

    Scenario: Reset Password (no password)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I press "Reset password"
        Then I should see "Password can't be blank"
	And I should be on "/password_resets/abc123"

    Scenario: Reset Password (too short)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "Password" with "a"
        And I fill in "Password confirmation" with "a"
        And I press "Reset password"
        Then I should see "Password is too short"
	And I should be on "/password_resets/abc123"

    Scenario: Reset Password (too easy)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "Password" with "aaaaaaaa"
        And I fill in "Password confirmation" with "aaaaaaaa"
        And I press "Reset password"
        Then I should see "Password does not use at least 2 different types of character"
	And I should be on "/password_resets/abc123"

    Scenario: Reset Password (no confirmation)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "Password" with "P@55word"
        And I press "Reset password"
        Then I should see "Password doesn't match confirmation"
	And I should be on "/password_resets/abc123"

    Scenario: Reset Password (password is email address)
        Given I have the following user records
            | email_address     | password |
            | alice@example.com | P@55word |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "Password" with "alice@example.com"
        And I fill in "Password confirmation" with "alice@example.com"
        And I press "Reset password"
        Then I should see "Password is not allowed to be your email address"
	And I should be on "/password_resets/abc123"

    Scenario: Reset Password (password contains part of name)
        Given I have the following user records
            | email_address     | password | name  |
            | alice@example.com | P@55word | Alice |
        And "alice@example.com" is an activated account
        And "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "Password" with "ali%%12HJ"
        And I fill in "Password confirmation" with "ali%%12HJ"
        And I press "Reset password"
        Then I should see "Password is not allowed to contain part of your name"
	And I should be on "/password_resets/abc123"
