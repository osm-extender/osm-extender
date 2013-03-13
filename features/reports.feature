@reports
@osm

Feature: Report OSM data
    As a section leader
    In order to make sense of the data in OSM
    I want to be able to run some reports

    Background:
    	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | badge      | read    |
	And an OSM request to get sections will give 1 sections


    Scenario: View list of reports
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Reports"
        Then I should be on the reports page
        And I should see "Test"
