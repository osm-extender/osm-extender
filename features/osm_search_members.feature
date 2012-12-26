@osm_search_members
@osm

Feature: Search Members
    As a section leader
    In order to find members matching a criteria
    I want to be able to retreieve a list of members and provide the criteria

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 roles
	And an OSM request to get sections will give 1 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | email1         |
	    | A1         | Member    | a1@example.com |
	    | A2         | Member    |                |
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |


    Scenario: Perform search
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Search members"
        Then I should be on the osm_search_members_form page
        When I check "selected_1_email1"
        And I fill in "search_for" with "example.COM"
        And I press "Search"
        Then I should be on the osm_search_members_results page
        And I should see "Section 1"
        And I should see "A1 Member"
        And I should not see "A2 Member"
