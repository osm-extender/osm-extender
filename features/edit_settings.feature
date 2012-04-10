@settings
@setting_value

Feature: Account Administration
    As an administrator of the site
    In order to configure the behaviour of the site
    I want to be able to edit the site's settings

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
	    | bob@example.com   | Bob   |
        And "alice@example.com" is an activated user account
        And "bob@example.com" is an activated user account
        And "alice@example.com" can "administer_settings"


    Scenario: Edit Settings
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer settings"
        Then I should see "test"
        And "test" should contain "a1b2c3d4"

        When I fill in "test" with "4d3c2b1a"
        And I press "Save changes"
        Then I should see "Settings updated."
        And "test" should contain "4d3c2b1a"


    Scenario: Edit Settings (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
        Then I should not see "Administer settings"

        When I go to the edit_settings page
        Then I should see "You are not authorised to do that."