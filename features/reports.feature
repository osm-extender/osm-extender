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
	And an OSM request to get sections will give 1 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | badge      | read    |


    Scenario: View list of reports
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Reports"
        Then I should be on the reports page
        And I should see "Due Badges"

    Scenario: Due Badges
	Given an OSM request to get due badges for section 1 and term 1 will result in the following being due their "Test" badge
	    | name  | completed | extra |
	    | Alice | 4         | info  |
	    | Bob   | 5         |       |
	When I signin as "alice@example.com" with password "P@55word"
	And I go to the reports page
	And I check "Check badge stock?"
	And I press "Show due badges"
	Then I should be on the due_badges_report page