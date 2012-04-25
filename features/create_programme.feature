@osm
@programme_create
@programme_wizard

Feature: Programme Wizard
    As a section leader
    In order to quickly add a term full of meetings to my programme
    I want to be able to specify a start date, end date, interval and meeting options

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
        And "alice@example.com" is connected to OSM


    Scenario: Add a term and meetings to the programme
	Given an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
            | programme  | write   |
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   | start      | end        |
	    | 1       | Term 1 | 2011-12-31 | 2013-02-01 |
	And an OSM request to add activity to programme will work
	And an OSM request to get programme for section 1 term 1 will have the evenings
	    | evening_id | meeting_date |
	    | 1          | 2012-01-01   |
	    | 2          | 2012-05-20   |
	    | 3          | 2012-10-07   |
	And an OSM request to update evening will work

        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Programme wizard"
        And I fill in "Programme start" with "2003-01-01"
        And I fill in "Programme end" with "2002-01-01"
        And I fill in "Evening start" with "11:00"
        And I fill in "Evening end" with "10:00"
        And I press "Create programme"
        Then I should see "Evening title can't be blank"
        And I should see "Programme end can't be before programme start"
        And I should see "Evening end can't be before evening start"
        And I should see "Programme start can't be before your terms (add/edit them in OSM)"

        When I fill in "Programme start" with "2012-01-01"
        And I fill in "Programme end" with "2013-01-01"
	And I fill in "Programme interval" with "140"
        And I fill in "Evening start" with "10:00"
        And I fill in "Evening end" with "11:00"
        And I fill in "Evening title" with "Test Meeting"
        And I press "Create programme"
        Then I should see "Your programme was created"
