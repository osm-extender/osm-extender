@my_account
@user

Feature: My Account
    As a user of the site
    In order to manage my account
    I want to edit my account
    And know that no one else can edit it
    And know that no one else can view it

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
	    | bob@example.com   |
        And "alice@example.com" is an activated user account


    Scenario: View Details
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
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "alice2@example.com"
	And I fill in "Name" with "Alice2"
	And I fill in "Current password" with "P@55word"
	And I press "Save changes"
        Then I should see "Sucessfully updated your details."
	And I should see "alice2@example.com"
	And I should see "Alice2"
	And I should be on the my_account page
	And user "alice2@example.com" should have email_address "alice2@example.com"
	And user "alice2@example.com" should have name "Alice2"

    Scenario: Edit Details (not signed in)
	When I go to the edit my account page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Edit Details (blank email address)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with ""
	And I fill in "Current password" with "P@55word"
	And I press "Save changes"
        Then I should see "Email address can't be blank"
	And I should be on the update_my_account page

    Scenario: Edit Details (bad email address)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "a"
	And I fill in "Current password" with "P@55word"
	And I press "Save changes"
        Then I should see "does not look like an email address"
	And I should be on the update_my_account page

    Scenario: Edit Details (existing email address)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "bob@example.com"
	And I fill in "Current password" with "P@55word"
	And I press "Save changes"
        Then I should see "Email address has already been taken"
	And I should be on the update_my_account page

    Scenario: Edit Details (no password when changing email address)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Email address" with "bob@example.com"
	And I press "Save changes"
        Then I should see "Incorrect current password"
	And I should be on the update_my_account page

    Scenario: Edit details (blank name)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the edit my account page
	And I fill in "Name" with ""
	And I press "Save changes"
        Then I should see "Name can't be blank"
	And I should be on the update_my_account page


    Scenario: Change Password
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "aA1&1234"
	And I fill in "password2" with "aA1&1234"
	And I press "Change password"
	Then I should see "Sucessfully changed your password."
	And I should be on the my_account page

    Scenario: Change Password (not signed in)
	When I go to the change my password page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Change Password (too easy)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "a"
	And I fill in "password2" with "a"
	And I press "Change password"
	Then I should see "isn't complex enough"
	And I should be on the update_my_password page

    Scenario: Change Password (no confirmation)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "aA1&1234"
	And I press "Change password"
	Then I should see "Password confirmation doesn't match Password"
	And I should be on the update_my_password page

    Scenario: Change Password (incorrect confirmation)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "aA1&1234"
	And I fill in "password2" with "abcdefgh"
	And I press "Change password"
	Then I should see "Password confirmation doesn't match Password"
	And I should be on the update_my_password page

    Scenario: Change Password (incorrect current password)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "wrong password"
	And I fill in "password1" with "aA1&1234"
	And I fill in "password2" with "aA1&1234"
	And I press "Change password"
	Then I should see "Incorrect current password."
	And I should be on the update_my_password page

    Scenario: Change Password (password is email address)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "alice@example.com"
	And I fill in "password2" with "alice@example.com"
	And I press "Change password"
	Then I should see "Password is not allowed to be your email address"
	And I should be on the update_my_password page

    Scenario: Change Password (password contains part of name)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the change my password page
	And I fill in "Current password" with "P@55word"
	And I fill in "password1" with "iceAA%%11"
	And I fill in "password2" with "iceAA%%11"
	And I press "Change password"
	Then I should see "Password is not allowed to contain part of your name"
	And I should be on the update_my_password page


    Scenario: Delete
	Given an OSM request to "get roles" will give 1 role
	And "alice@example.com" is connected to OSM
	And "alice@example.com" has a reminder email for section 1 on "Tuesday" with all items
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | none    |
	And I have no PaperTrail::Versions
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the delete my account page
	Then I should be on the confirm delete my account page
	And I should see "1 reminder email"
	When I fill in "password" with "P@55word"
	And I press "Delete my account"
	Then I should see "Your account was deleted"
	And I should be on the root page
	And I should have 1 users
	And I should have 0 email reminders
	And I should have 0 email reminder items
	And I should have 0 email lists
	And I should have 0 PaperTrail::Versions

    Scenario: Delete (wrong password)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the delete my account page
	And I fill in "password" with "WRONG"
	And I press "Delete my account"
	Then I should see "Incorrect password"
	And I should be on the confirm delete my account page

