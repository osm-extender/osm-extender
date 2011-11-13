@signup
@user
@email

Feature: Sign up
    As a new user of the site
    In order to use the site
    I want to be able to create an account

    As a site administrator
    In order to better support users
    I want to know users have a valid email address


    Background:
        Given I have no users


    Scenario: Signup
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "P@55word"
        And I fill in "Password confirmation" with "P@55word"
        And I press "Sign up"
        Then I should have 1 user
        And I should see "Your signup was successful"
	And I should be on the root page
        And "somebody@somewhere.com" should receive an email with subject /Activate Your Account/
        When I open the email with subject /Activate Your Account/
        When I click the first link in the email
        Then I should see "Your account was successfully activated."
	And I should be on the signin page
        And "somebody@somewhere.com" should receive an email with subject /Your Account Has Been Activated/

    Scenario: Signup (no name)
        When I go to the signup page
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "P@55word"
        And I fill in "Password confirmation" with "P@55word"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Name can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (no password)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (password too easy)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "a"
        And I fill in "Password confirmation" with "a"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "isn't complex enough"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (no password confirmation)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password doesn't match confirmation"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (password is email address)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "somebody@somewhere.com"
        And I fill in "Password confirmation" with "somebody@somewhere.comm"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password is not allowed to be your email address"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (password contains part of name)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "Som890%^"
        And I fill in "Password confirmation" with "Som890%^"
        And I press "Sign up"
        Then I should see "Password is not allowed to contain part of your name"
	And I should be on the users page
        And I should have 0 users
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (no email)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Email address can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (invalid email)
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "a"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Email address does not look like an email address"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/

    Scenario: Signup (duplicated email)
        Given I have the following user records
            | email_address     |
            | alice@example.com |
        And "alice@example.com" is an activated user account
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "alice@example.com"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 1 user
        And I should see "Email address has already been taken"
        And I should not see "Your signup was successful"
	And I should be on the users page
        And "somebody@somewhere.com" should receive no email with subject /Activate Your Account/


    Scenario: Activate Account (bad token)
        Given I have no users
        When I go to activate_account token="123abc"
        Then I should see "We were unable to activate your account."
	And I should be on the root page
