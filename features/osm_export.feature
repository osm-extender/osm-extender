@osm_export
@osm

Feature: Export OSM data
    As a section leader who is a geek
    In order to use my OSM data
    I want to be able to export it as a TSV or CSV file

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
	    | programme  | read    |
	    | flexi      | read    |
	And an OSM request to get sections will give 1 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |


    Scenario: Export Members CSV without headers
	Given an OSM request to get groupings for section 1 will have the groupings
	    | grouping_id | name     |
	    | 1           | Grouping |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | grouping_id | date_of_birth |
	    | A          | Member    | 1           | 2000-01-01    |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I uncheck "Include header line" in the "members" form
        And I select "Comma" from "Column separator" in the "members" form
        And I press "Export members" in the "members" form
        Then I should get a download with filename "1stSomewhere_Section1_Members.csv" and MIME type "text/csv"
        And the body should contain "1,A,Member,Grouping,6/0,"","","","","","","","","","","","","",Male,"","","",,,,,,,,,,2000-01-01,2006-01-01,2006-01-01,1,1,0"
        And the body should not contain "First Name, Last Name"

    Scenario: Export Members TSV with headers
	Given an OSM request to get groupings for section 1 will have the groupings
	    | grouping_id | name     |
	    | 1           | Grouping |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | grouping_id | date_of_birth |
	    | A          | Member    | 1           | 2000-01-01    |
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the osm_export page
        And I check "Include header line" in the "members" form
        And I select "Tab" from "Column separator" in the "members" form
        And I press "Export members" in the "members" form
        Then I should get a download with filename "1stSomewhere_Section1_Members.tsv" and MIME type "text/tsv"
        And the body should contain "First Name	Last Name"
        And the body should contain "A	Member"

    Scenario: Export Programme Meetings
	Given an OSM request to get programme for section 1 term 1 will have 2 programme items
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I press "Export programme meetings" in the "programme_meetings" form
        Then I should get a download with filename "1stSomewhere_Section1_ProgrammeMeetings.csv" and MIME type "text/csv"
        And the body should contain "19:15,20:30,Weekly Meeting 1,"","","","","""
	And the body should contain "19:15,20:30,Weekly Meeting 2,"","","","","""

    Scenario: Export Programme Activities
	Given an OSM request to get programme for section 1 term 1 will have 2 programme items
	And an OSM request to get activity 11 will have tags "global"
	And an OSM request to get activity 12 will have tags "outdoors"
	And an OSM request to get activity 21 will have tags "belief, values"
	And an OSM request to get activity 22 will have tags "global, outdoors"
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I press "Export programme activities" in the "programme_activities" form
        Then I should get a download with filename "1stSomewhere_Section1_ProgrammeActivities.csv" and MIME type "text/csv"
        And the body should contain "1,11,Activity 11,"""
        And the body should contain "1,12,Activity 12,"""
        And the body should contain "2,21,Activity 21,"""
        And the body should contain "2,22,Activity 22,"""

    Scenario: Export Flexi Record
	Given an OSM request to get_flexi_record_fields for section "1" flexi "101" will have the fields
	    | id         | name       |
	    | f_01       | Custom     |
	And an OSM request to get_flexi_record_data for section "1" flexi "101" term "1" will have the data
	    | firstname | lastname | f_01 |
	    | John      | Smith    | A    |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I check "Include header line" in the "flexi_record" form
        And I press "Export flexi record" in the "flexi_record" form
        Then I should get a download with filename "1stSomewhere_Section1_Flexi1.csv" and MIME type "text/csv"
        And the body should contain "Member ID,First name,Last name,Custom"
        And the body should contain "0,John,Smith,A"
