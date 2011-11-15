@user_admin
@user
@email

Feature: Account Administration
    As an administrator of the site
    In order to manage user accounts
    I want to edit user permissions
    And I want to edit users
    And I want to reset a forgotten password
    And I want to be able to resend the account activation email

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
	    | bob@example.com   | Bob   |
            | chris@example.com | Chris |
        And "alice@example.com" is an activated user account
        And "chris@example.com" is an activated user account
        And "alice@example.com" can "administer_users"
	And no emails have been sent


    Scenario: View Users
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
        Then I should see "alice@example.com"
        And I should see "bob@example.com"
        And I should see "chris@example.com"

    Scenario: View Users (Not authorised)
        When I signin as "chris@example.com" with password "P@55word"
        And I go to the list of users
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: View Users (Not signed in)
	When I go to the list of users
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Edit User (Not authorised)
        When I signin as "chris@example.com" with password "P@55word"
        And I go to edit the user "alice@example.com"
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: Edit User (Not signed in)
        When I go to edit the user "alice@example.com"
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Edit User's Name
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	And I follow "Edit user" in the "Actions" column of the "chris@example.com" row
	And I fill in "Name" with "Christine"
	And I press "Update"
	Then I should see "The user was updated."
	And I should be on the list of users
	And there should be no emails
	And user "chris@example.com" should have name "Christine"

    Scenario: Edit User's Email Address
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	And I follow "Edit user" in the "Actions" column of the "chris@example.com" row
	And I fill in "Email address" with "chris2@example.com"
	And I press "Update"
	Then I should see "The user was updated."
	And I should be on the list of users
        And "chris@example.com" should receive an email with subject /Email Address Changed/
	And user "chris2@example.com" should have email_address "chris2@example.com"

    Scenario: Add User's Permission
	Given "chris@example.com" can not "administer_users"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	And I follow "Edit user" in the "Actions" column of the "chris@example.com" row
	And I check "Can administer users"
	And I press "Update"
	Then I should see "The user was updated."
	And I should be on the list of users
	And there should be no emails
	And "chris@example.com" should be able to "administer_users"

    Scenario: Remove User's Permission
	Given "chris@example.com" can "administer_users"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	When I follow "Edit user" in the "Actions" column of the "chris@example.com" row
	And I uncheck "Can administer users"
	And I press "Update"
	Then I should see "The user was updated."
	And I should be on the list of users
	And there should be no emails
	And "chris@example.com" should not be able to "administer_users"



    Scenario: Reset Password
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	And I follow "Reset password" in the "Actions" column of the "chris@example.com" row
	Then I should see "Instructions have been sent to the user."
	And I should be on the list of users
        And "chris@example.com" should receive an email with subject /Password Reset/

    Scenario: Reset Password (Not authorised)
        When I signin as "chris@example.com" with password "P@55word"
        And I post to reset the password for "alice@example.com"
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: Reset Password (Not signed in)
        When I post to reset the password for "alice@example.com"
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Resend Activation Email
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of users
	Then the "Actions" column of the "chris@example.com" row should not see "Resend activation email"
	And the "Actions" column of the "bob@example.com" row should see "Resend activation email"
	When I follow "Resend activation email" in the "Actions" column of the "bob@example.com" row
	Then I should see "Activation instructions have been sent to the user."
	And I should be on the list of users
        And "bob@example.com" should receive an email with subject /Activate Your Account/

    Scenario: Resend Activation Email (Not authorised)
        When I signin as "chris@example.com" with password "P@55word"
        And I go to resend the activation email for "bob@example.com"
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: Resend Activation Email (Not signed in)
        When I go to resend the activation email for "bob@example.com"
	Then I should see "You must be signed in"
	And I should be on the signin page
