@forgotten_password
@user
@user_mailer

Feature: Forgotten Password
    As a user of the site
    In order to recover from forgetting my password
    I want to reset my password


    Background:
	Given I have no users
        And I have the following user records
            | email_address     |
            | alice@example.com |
        And "alice@example.com" is an activated user account


    @send_email
    Scenario: Forgotten Password
        When I go to the signin page
        And I follow "Forgotten your password?"
        And I fill in "Email address" with "alice@example.com"
        And I press "Request password reset"
        Then I should see "Instructions have been sent to your email address."
	And I should be on the root page
        And "alice@example.com" should receive an email with subject /Password Reset/
        When I open the email with subject /Password Reset/
        When I click the /reset_password/ link in the email
        When I fill in "password1" with "P@55word"
        And I fill in "password2" with "P@55word"
        And I press "Reset password"
        Then I should see "Password sucessfully changed."
	And I should be on the root page


    Scenario: Forgotten Password (bad email address)
        When I go to the signin page
        And I follow "Forgotten your password?"
        And I fill in "Email address" with "bob@example.com"
        And I press "Request password reset"
        Then I should see "Instructions have been sent to your email address."
	And I should be on the root page
        And "bob@example.com" should receive no email with subject /Password Reset/


    Scenario: Reset Password (bad token)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="123abc"
	And I should be on the root page

    Scenario: Reset Password (no password)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I press "Reset password"
        Then I should see "Password can't be blank"
	And I should be on "/password_resets/abc123"
        And "alice@example.com" should receive no email with subject /Password Changed/

    Scenario: Reset Password (too easy)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "password1" with "a"
        And I fill in "password2" with "a"
        And I press "Reset password"
        Then I should see "isn't complex enough"
	And I should be on "/password_resets/abc123"
        And "alice@example.com" should receive no email with subject /Password Changed/

    Scenario: Reset Password (no confirmation)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "password1" with "P@55word"
        And I press "Reset password"
        Then I should see "Password doesn't match confirmation"
	And I should be on "/password_resets/abc123"
        And "alice@example.com" should receive no email with subject /Password Changed/

    Scenario: Reset Password (password is email address)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "password1" with "alice@example.com"
        And I fill in "password2" with "alice@example.com"
        And I press "Reset password"
        Then I should see "Password is not allowed to be your email address"
	And I should be on "/password_resets/abc123"
        And "alice@example.com" should receive no email with subject /Password Changed/

    Scenario: Reset Password (password contains part of name)
        Given "alice@example.com" has password_reset_token "abc123"
        When I go to reset_password token="abc123"
        And I fill in "password1" with "ali%%12HJ"
        And I fill in "password2" with "ali%%12HJ"
        And I press "Reset password"
        Then I should see "Password is not allowed to contain part of your name"
	And I should be on "/password_resets/abc123"
        And "alice@example.com" should receive no email with subject /Password Changed/


    @send_email
    Scenario: Reset token on a successful signin
        When I go to the signin page
        And I follow "Forgotten your password?"
        And I fill in "Email address" with "alice@example.com"
        And I press "Request password reset"
        Then I should see "Instructions have been sent to your email address."
        When I signin as "alice@example.com" with password "wrong"
	Then "alice@example.com" should have a password reset token
        When I signin as "alice@example.com" with password "P@55word"
	Then "alice@example.com" should not have a password reset token
