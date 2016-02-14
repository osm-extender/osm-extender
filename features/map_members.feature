@map_members
@osm

Feature: Map Members
    As a section leader
    In order to satisfy my curiousity
    I want to be able to view a map of where my members live

    Background:
	Given I have no users
        And I have no usage log records
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get sections will give 1 section
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	And an OSM request to get groupings for section 1 will have the groupings
	    | grouping_id | name |
	    | 1           | A    |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name |
	    | A          | Member    |
	    | B          | Member    |

    Scenario: Index page -> Section
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the map_members_index page
        And I follow "1st Somewhere : Section 1"
        Then I should be on the page for map_members 1

    Scenario: Index page -> Multiple
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the map_members_index page
        And I follow "Get a map for members from multiple sections"
        Then I should be on the map_members_multiple page



    Scenario: Get page
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the page for map_members 1
        Then I should be on the page for map_members 1
        And I should have 1 usage log record

    Scenario: Get data
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the page for map_members_data 1
        Then I should be on the page for map_members_data 1
        And I should have 2 usage log records
        And I should have the following usage log
            | user              | controller           | action |
            | alice@example.com | MapMembersController | data   |


    Scenario: Get page (not signed in)
		When I go to the page for map_members 1
		Then I should see "You must be signed in"
		And I should be on the signin page
        And I should have 0 usage log records

    Scenario: Get data (not signed in)
		When I go to the page for map_members_data 1
		Then I should see "You must be signed in"
		And I should be on the signin page
        And I should have 0 usage log records


    Scenario: Get page (incorrect OSM permission)
		Given an OSM request to get_api_access for section "1" will have the permissions
		    | permission | granted |
		    | member     | none    |
        When I signin as "alice@example.com" with password "P@55word"
		And I go to the page for map_members 1
		Then I should see "You do not have the correct OSM permissions"
		And I should be on the check_osm_setup page
        And I should have 1 usage log records

    Scenario: Get data (incorrect OSM permission)
		Given an OSM request to get_api_access for section "1" will have the permissions
		    | permission | granted |
		    | member     | none    |
        When I signin as "alice@example.com" with password "P@55word"
		And I go to the page for map_members_data 1
		Then I should see "You do not have the correct OSM permissions"
		And I should be on the check_osm_setup page
		And I should have 1 usage log records



    Scenario: Get multiple page
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the map_members_multiple page
        And I should have 1 usage log record

    Scenario: Get multiple data
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the map_members_multiple_data page
        Then I should be on the map_members_multiple_data page
        And I should have 2 usage log records
        And I should have the following usage log
            | user              | controller           | action          |
            | alice@example.com | MapMembersController | multiple_data   |


    Scenario: Get multiple page (not signed in)
		When I go to the map_members_multiple page
		Then I should see "You must be signed in"
		And I should be on the signin page
	    And I should have 0 usage log records

    Scenario: Get multiple data (not signed in)
		When I go to the map_members_multiple_data page
		Then I should see "You must be signed in"
		And I should be on the signin page
	    And I should have 0 usage log records
