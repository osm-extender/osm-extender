Feature: My Account
    As a user of the site
    In order to manage my account
    I want to edit my account
    And know that no one else can edit it
    And know that no one else can view it


    Scenario: View Details
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
	    | bob@example.com   |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the my account page
        Then I should see "alice@example.com"
        And I should not see "bob@example.com"
	And I should be on the my_account page

    Scenario: View Details (not signed in)
	When I go to the my account page
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Edit Details
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
	    | bob@example.com   |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "alice2@example.com"
	And I fill in "Name" with "Alice2"
	And I press "Save changes"
        Then I should see "Sucessfully updated your details."
	And I should see "alice2@example.com"
	And I should see "Alice2"
	And I should be on the my_account page
        And "alice@example.com" should receive an email with subject /Email Address Changed/
	When I open the email
	Then I should see "alice2@example.com"

    Scenario: Edit Details (not signed in)
	When I go to the edit my account page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Edit Details (blank email address)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with ""
	And I press "Save changes"
        Then I should see "Email address can't be blank"
	And I should be on the update_my_account page

    Scenario: Edit Details (bad email address)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "a"
	And I press "Save changes"
        Then I should see "does not look like an email address"
	And I should be on the update_my_account page

    Scenario: Edit Details (existing email address)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
	    | bob@example.com   |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "bob@example.com"
	And I press "Save changes"
        Then I should see "Email address has already been taken"
	And I should be on the update_my_account page

    Scenario: Edit details (blank name)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Name" with ""
	And I press "Save changes"
        Then I should see "Name can't be blank"
	And I should be on the update_my_account page

    
    Scenario: Change Password
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "aA1&1234"
	And I fill in "New password confirmation" with "aA1&1234"
	And I press "Change password"
	Then I should see "Sucessfully changed your password."
	And I should be on the my_account page
        And "alice@example.com" should receive an email with subject /Password Changed/

    Scenario: Change Password (not signed in)
	When I go to the change my password page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Change Password (too easy)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "a"
	And I fill in "New password confirmation" with "a"
	And I press "Change password"
	Then I should see "isn't complex enough"
	And I should be on the update_my_password page

    Scenario: Change Password (no confirmation)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "aA1&1234"
	And I press "Change password"
	Then I should see "Password doesn't match confirmation"
	And I should be on the update_my_password page

    Scenario: Change Password (incorrect confirmation)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "aA1&1234"
	And I fill in "New password confirmation" with "abcdefgh"
	And I press "Change password"
	Then I should see "Password doesn't match confirmation"
	And I should be on the update_my_password page

    Scenario: Change Password (incorrect current password)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "wrong password"
	And I fill in "New password" with "aA1&1234"
	And I fill in "New password confirmation" with "aA1&1234"
	And I press "Change password"
	Then I should see "Incorrect current password."
	And I should be on the update_my_password page

    Scenario: Change Password (password is email address)
        Given I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "alice@example.com"
	And I fill in "New password confirmation" with "alice@example.com"
	And I press "Change password"
	Then I should see "Password is not allowed to be your email address"
	And I should be on the update_my_password page

    Scenario: Change Password (password contains part of name)
        Given I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "New password" with "iceAA%%11"
	And I fill in "New password confirmation" with "iceAA%%11"
	And I press "Change password"
	Then I should see "Password is not allowed to contain part of your name"
	And I should be on the update_my_password page
