@map_members
@osm

Feature: Map Members
    As a section leader
    In order to satisfy my curiousity
    I want to be able to view a map of where my members live

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
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

    Scenario: Get page
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Map members"
        Then I should be on the map_members page

    Scenario: Get data
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the map_members_data page
        Then I should be on the map_members_data page


    Scenario: Get page (not signed in)
	When I go to the map_members page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Get data (not signed in)
	When I go to the map_members_data page
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Get page (incorrect OSM permission)
	Given an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | none    |
        When I signin as "alice@example.com" with password "P@55word"
	And I go to the map_members page
	Then I should see "You do not have the correct OSM permissions"
	And I should be on the osm_permissions page

    Scenario: Get data (incorrect OSM permission)
	Given an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | none    |
        When I signin as "alice@example.com" with password "P@55word"
	And I go to the map_members_data page
	Then I should see "You do not have the correct OSM permissions"
	And I should be on the osm_permissions page
