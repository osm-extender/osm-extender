@view_details
@osm

Feature: View contact details
    As a section leader
    In order to better correct printed contact details
    I want to be able to print them to my ideal size

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
	    | member     | read    |
	And an OSM request to get sections will give 1 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | email1         | email2         | email3         | email4         | grouping_id |
	    | A          | Member    | a1@example.com | a2@example.com | a3@example.com | a4@example.com | 1           |


    Scenario: Show details
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Contact details"
        Then I should be on the osm_details_fields page
        When I check "fields_email1"
        And I check "fields_email2"
        And I uncheck "fields_email3"
        And I uncheck "fields_email4"
        And I uncheck "fields_phone1"
        And I uncheck "fields_phone2"
        And I uncheck "fields_phone3"
        And I uncheck "fields_phone4"
        And I uncheck "fields_address"
        And I uncheck "fields_address2"
        And I uncheck "fields_subs"
        And I uncheck "fields_medical"
        And I uncheck "fields_ethnicity"
        And I uncheck "fields_religion"
        And I uncheck "fields_school"
        And I press "Show details"
        Then I should be on the osm_details_show page
        And I should see "a1@example.com"
        And I should see "a2@example.com"
        And I should not see "a3@example.com"
        And I should not see "a4@example.com"


    Scenario: Show details (not signed in)
	When I go to the osm_details_fields page
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Show details without selecting any fields
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Contact details"
        Then I should be on the osm_details_fields page
        When I uncheck "fields[email1]"
        And I uncheck "fields[email2]"
        And I uncheck "fields[email3]"
        And I uncheck "fields[email4]"
        And I uncheck "fields[phone1]"
        And I uncheck "fields[phone2]"
        And I uncheck "fields[phone3]"
        And I uncheck "fields[phone4]"
        And I uncheck "fields[address]"
        And I uncheck "fields[address2]"
        And I uncheck "fields[subs]"
        And I uncheck "fields[medical]"
        And I uncheck "fields[ethnicity]"
        And I uncheck "fields[religion]"
        And I uncheck "fields[school]"
        And I press "Show details"
        Then I should be on the osm_details_fields page
        And I should see "You must select some fields to view."
