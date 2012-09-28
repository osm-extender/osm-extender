@flexi_records
@osm

Feature: Flexi Records
    As a section leader
    In order to better correct printed flexi records
    I want to be able to print them to my idea size

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
	    | flexi      | read    |


    Scenario: Get list of flexi records
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Flexi records"
        Then I should be on the osm_flexi_records page
        And I should see "Flexi 1"
        And I should see "Flexi 2"

    Scenario: Show a flexi record
	Given an OSM request to get_flexi_record_fields for section "1" flexi "101" will have the fields
	    | id         | name       |
	    | firstname  | First name |
	    | lastname   | last name  |
	    | f_01       | Custom 1   |
	    | f_02       | Custom 2   |
	And an OSM request to get_flexi_record_data for section "1" flexi "101" term "1" will have the data
	    | firstname | lastname | f_01 | f_02 |
	    | John      | Smith    | A    | B    |
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |

        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Flexi records"
        And I follow "[Show]" in the "Actions" column of the "Flexi 1" row
        Then I should see "Flexi 1 for Section 1"
        And I should see "First name"
        And I should see "Last name"
        And I should see "Custom 1"
        And I should see "Custom 2"
	And I should see "Smith" in the "Last name" column of the "John" row
	And I should see "A" in the "Custom 1" column of the "John" row
	And I should see "B" in the "Custom 2" column of the "John" row


    Scenario: Show flexi records (not signed in)
	When I go to the osm_flexi_records page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Show a flexi record (not signed in)
	When I go to the page for osm_flexi_record 1
	Then I should see "You must be signed in"
	And I should be on the signin page
