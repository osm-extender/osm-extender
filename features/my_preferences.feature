@my_preferences
@user

Feature: My Preferences
    As I user of the site
    In order to make it more usable by me
    I want to be able to set some preferences

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 2 roles
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	And an OSM request to get_api_access for section "2" will have the permissions
	    | permission | granted |
	    | member     | read    |


    Scenario: Setting start up section
        When I signin as "alice@example.com" with password "P@55word"
	Then I should be on the my_page page
        And I should see "Current section: Section 1 (1st Somewhere)"

        When I select "1st Somewhere : Section 2" from "Startup section"
        And I press "Save preferences"
        Then I should see "Your preferences were updated."
        
        When I signout
        And I signin as "alice@example.com" with password "P@55word"
        Then I should see "Current section: Section 2 (1st Somewhere)"
