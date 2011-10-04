Feature: Sign up
    As a new user of the site
    In order to use the site
    I want to be able to create an account

    As a site administrator
    In order to better support users
    I want to know users have a valid email address

    Scenario: Signup
        Given I have no users
        And no emails have been sent
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
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
        Given I have no users
        When I go to the signup page
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Name can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (no password)
        Given I have no users
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (password too short)
        Given I have no users
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "a"
        And I fill in "Password confirmation" with "a"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password is too short"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (password too easy)
        Given I have no users
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "aaaaaaaa"
        And I fill in "Password confirmation" with "aaaaaaaa"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password does not use at least 2 different types of character"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (no password confirmation)
        Given I have no users
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Email address" with "somebody@somewhere.com"
        And I fill in "Password" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Password doesn't match confirmation"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (no email)
        Given I have no users
        When I go to the signup page
        And I fill in "Name" with "Somebody"
        And I fill in "Password" with "aB3$hj37"
        And I fill in "Password confirmation" with "aB3$hj37"
        And I press "Sign up"
        Then I should have 0 users
        And I should see "Email address can't be blank"
        And I should not see "Your signup was successful"
	And I should be on the users page

    Scenario: Signup (invalid email)
        Given I have no users
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

    Scenario: Signup (duplicated email)
        Given I have no users
        And I have the following user records
            | email_address     | password |
            | alice@example.com | Alice%12 |
        And "alice@example.com" is an activated account
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


    Scenario: Activate Account (bad token)
        Given I have no users
        When I go to activate_account token="123abc"
        Then I should see "We were unable to activate your account."
	And I should be on the root page
