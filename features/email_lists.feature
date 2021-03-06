@email_lists
@osm

Feature: Email Lists
    As a section leader
    In order to keep in touch with members of the section
    I want to be able to retreieve a list of email addresses
    And I want to be able to save these lists

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 2 roles
	And an OSM request to get sections will give 2 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | contact_email1 | primary_email2 | secondary_email1 | emergency_email1 | grouping_id |
	    | A          | Member    | a1@example.com | a2@example.com | a3@example.com   | a4@example.com   | 1           |
	    | B          | Member    | b1@example.com | b2@example.com | b3@example.com   | b4@example.com   | 2           |
	    | C          | Member    |                |                |                  |                  | 1           |
	    | A2         | Member    | a1@example.com | a2@example.com | a3@example.com   | a4@example.com   | 1           |
	And an OSM request to get groupings for section 1 will have the groupings
	    | grouping_id | name |
	    | 1           | A    |
	    | 2           | B    |
	And an OSM request to get groupings for section 2 will have the groupings
	    | grouping_id | name |
	    | 21          | 2A   |
	    | 22          | 2B   |
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	And an OSM request to get_api_access for section "2" will have the permissions
	    | permission | granted |
	    | member     | read    |


    Scenario: Get list of member addresses (are in a six)
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Email lists"
        Then I should be on the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "Only email 1" from "email_list[contact_member]"
        And I select "are" from "email_list[match_type]"
        And I select "A" from "email_list[match_grouping]"
        And I press "Get addresses"
        Then I should see "a1@example.com"
        And I should not see "a2@example.com"
        And I should not see "b1@example.com"
        And I should not see "b2@example.com"
	And I should not see "A Member"
	And I should not see "B Member"
	And I should see "C Member"
	And I should not see "A2 Member"

    Scenario: Get list of addresses (are not in a six)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "Only email 2" from "email_list[contact_primary]"
        And I select "are not" from "email_list[match_type]"
        And I select "A" from "email_list[match_grouping]"
        And I press "Get addresses"
        Then I should see "b2@example.com"
        And I should not see "a1@example.com"
        And I should not see "a2@example.com"
        And I should not see "b1@example.com"
	And I should not see "A Member"
	And I should not see "B Member"
	And I should not see "C Member"
	And I should not see "A2 Member"

    Scenario: Get list of addresses (everyone)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "All emails" from "email_list[contact_member]"
        And I select "All emails" from "email_list[contact_primary]"
        And I select "All emails" from "email_list[contact_secondary]"
        And I select "All emails" from "email_list[contact_emergency]"
        And I select "are" from "email_list[match_type]"
        And I select "Any" from "email_list[match_grouping]"
        And I press "Get addresses"
        Then I should see "a1@example.com"
        And I should see "a2@example.com"
        And I should see "a3@example.com"
        And I should see "a4@example.com"
        And I should see "b1@example.com"
        And I should see "b2@example.com"
        And I should see "b3@example.com"
        And I should see "b4@example.com"
	And I should not see "A Member"
	And I should not see "B Member"
	And I should see "C Member"
	And I should not see "A2 Member"

    Scenario: Get list of addresses (not everyone)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "None" from "email_list[contact_member]"
        And I select "None" from "email_list[contact_primary]"
        And I select "None" from "email_list[contact_secondary]"
        And I select "None" from "email_list[contact_emergency]"
        And I select "are" from "email_list[match_type]"
        And I select "Any" from "email_list[match_grouping]"
        And I press "Get addresses"
	Then I should see "You must select at least one contact to get some addresses for."
	And I should be on the email_lists page

    Scenario: Get list of addresses (without selecting any addresses)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "None" from "email_list[contact_member]"
        And I select "None" from "email_list[contact_primary]"
        And I select "None" from "email_list[contact_secondary]"
        And I select "None" from "email_list[contact_emergency]"
        And I select "are" from "email_list[match_type]"
        And I select "Any" from "email_list[match_grouping]"
        And I press "Get addresses"
	Then I should be on the email_lists page
	And I should see "You must select at least one contact to get some addresses for."
        And I should not see "a1@example.com"
        And I should not see "a2@example.com"
        And I should not see "a3@example.com"
        And I should not see "a4@example.com"
        And I should not see "b1@example.com"
        And I should not see "b2@example.com"
        And I should not see "b3@example.com"
        And I should not see "b4@example.com"
	And I should not see "A Member"
	And I should not see "B Member"
	And I should not see "C Member"

    Scenario: Get list of addresses (not signed in)
	When I go to the email_lists page
	Then I should see "You must be signed in"
	And I should be on the signin page



    Scenario: Save a search
	Given an OSM request to get members for section 2 in term 2 will have the members
	    | first_name | last_name | contact_email1 | primary_email2 | grouping_id |
	    | A          | Member    | a1@example.com | a2@example.com | 21          |
	And an OSM request to get terms for section 2 will have the term
	    | term_id | name   |
	    | 2       | Term 2 |
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	And I select "1st Somewhere : Section 2" from "email_list[section_id]"
        And I select "All emails" from "email_list[contact_member]"
        And I press "Get addresses"
	And I fill in "Name" with "Test list"
	And I press "Save this list"
	Then I should see "Email list was successfully created"
	And I should be on the email_lists page
	And I should see "Section 2" in the "Section" column of the "Test list" row

    Scenario: Run a saved search
	Given "alice@example.com" has a saved email list "Test list" for section "1"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	And I follow "[Get addresses]" in the "Actions" column of the "Test list" row
        Then I should see "a1@example.com"

    Scenario: View saved searches
        Given I have the following user records
	    | email_address     | name  |
	    | bob@example.com   | Bob   |
        And "bob@example.com" is an activated user account
	And "bob@example.com" is connected to OSM
        And an OSM request to get terms will have the terms
            |section_id | term_id | name   |
            | 1         | 1       | Term 1 |
            | 2         | 2       | Term 2 |
	And "alice@example.com" has a saved email list "Test list" for section "1"
	And "alice@example.com" has a saved email list "Test list 2" for section "2"
	And "bob@example.com" has a saved email list "Test list 3" for section "1"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
        Then I should see "Test list"
        And I should see "Test list 2"
        And I should not see "Test list 3"

    Scenario: Edit a saved search
	Given "alice@example.com" has a saved email list "Test list" for section "1"
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the email_lists page
	And I follow "[Edit]" in the "Actions" column of the "Test list" row
	Then the "email_list[notify_changed]" checkbox should be checked
        And I uncheck "email_list[notify_changed]"
	And I press "Update Email list"
	Then I should see "Email list was successfully updated"
	And I should be on the email_lists page
	When I follow "[Edit]" in the "Actions" column of the "Test list" row
        Then the "email_list[notify_changed]" checkbox should not be checked


    Scenario: View multiple saved searches
	Given "alice@example.com" has a saved email list "Test list" for section "1"
	And "alice@example.com" has a saved email list "Test list 2" for section "1"
	And "alice@example.com" has a saved email list "Test list 3" for section "1"
    When I signin as "alice@example.com" with password "P@55word"
    And I go to the email_lists page
	And I check "email_list_1"
	And I check "email_list_2"
	And I press "selected_get_addresses"

	Then I should see "Test list"
	And I should see "Test list 2"
	And I should not see "Test list 3"
        And I should see "a1@example.com"
        And I should see "a2@example.com"
        And I should see "a3@example.com"
        And I should see "a4@example.com"
        And I should see "b1@example.com"
        And I should see "b2@example.com"
        And I should see "b3@example.com"
        And I should see "b4@example.com"


    Scenario: Deduplication of addresses should be case insensitive (single list)
	Given an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | contact_email1 | grouping_id |
	    | A          | Member    | a1@example.com | 1           |
	    | B          | Member    | A1@example.com | 1           |
	    | C          | Member    | a1@example.com | 1           |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Email lists"
        Then I should be on the email_lists page
	When I select "1st Somewhere : Section 1" from "email_list[section_id]"
        And I select "All emails" from "email_list[contact_member]"
        And I select "are" from "email_list[match_type]"
        And I select "A" from "email_list[match_grouping]"
	And I press "Get addresses"
        Then I should see "a1@example.com"
	And I should not see "A1@example.com"
