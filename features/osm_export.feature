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
	And an OSM request to get sections will give 1 sections
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | first_name | last_name | grouping_id | date_of_birth |
	    | A          | Member    | 1           | 2000-01-01    |
	And an OSM request to get programme for section 1 term 1 will have 2 programme items
	And an OSM request to get activity 11 will have tags "global"
	And an OSM request to get activity 12 will have tags "outdoors"
	And an OSM request to get activity 21 will have tags "belief, values"
	And an OSM request to get activity 22 will have tags "global, outdoors"


    Scenario: Export CSV without headers
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I choose "Members"
        And I uncheck "Include header line"
        And I select "Comma" from "Column separator"
        And I press "Export data"
        Then I should get a download with filename "1stSomewhere_Section1_Members.csv" and MIME type "text/csv"
        And the body should contain "1,A,Member,"",6/0,"","","","","","","","","","","","","",Male,"","","",,,,,,,,,,2000-01-01,2006-01-01,2006-01-01,1,1,0"
        And the body should not contain "First Name, Last Name"

    Scenario: Export TSV with headers
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the osm_export page
        And I choose "Members"
        And I check "Include header line"
        And I select "Tab" from "Column separator"
        And I press "Export data"
        Then I should get a download with filename "1stSomewhere_Section1_Members.tsv" and MIME type "text/tsv"
        And the body should contain "First Name	Last Name"
        And the body should contain "A	Member"

    Scenario: Export programme meetings
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I choose "Meetings"
        And I press "Export data"
        Then I should get a download with filename "1stSomewhere_Section1_Meetings.csv" and MIME type "text/csv"
        And the body should contain "1,2013-02-06,19:15,20:30,Weekly Meeting 1,"","","","","""
	And the body should contain "2,2013-02-07,19:15,20:30,Weekly Meeting 2,"","","","","""

    Scenario: Export programme activities
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM export"
        And I choose "Activities"
        And I press "Export data"
        Then I should get a download with filename "1stSomewhere_Section1_Activities.csv" and MIME type "text/csv"
        And the body should contain "1,11,Activity 11,"""
        And the body should contain "1,12,Activity 12,"""
        And the body should contain "2,21,Activity 21,"""
        And the body should contain "2,22,Activity 22,"""
