@balanced_programme
@osm

Feature: Balanced Programme
    As a section leader
    In order to access how balanced my programme is
    I want to be able to view how well I'm meeting each method and zone

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
	And an OSM request to get programme for section 1 term 1 will have 2 programme items
	And an OSM request to get activity 11 will have tags "global"
	And an OSM request to get activity 12 will have tags "outdoors"
	And an OSM request to get activity 21 will have tags "belief, values"
	And an OSM request to get activity 22 will have tags "global, outdoors"

    Scenario: Get balanced programme
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Programme review"
        Then I should be on the programme_review_balanced page

    Scenario: Get balanced programme data
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the programme_review_balanced_data page
        Then I should be on the programme_review_balanced_data page


    Scenario: Get balanced programme (not signed in)
	When I go to the programme_review_balanced page
	Then I should see "You must be signed in"
	And I should be on the signin page

    Scenario: Get balanced programme data (not signed in)
	When I go to the programme_review_balanced_data page
	Then I should see "You must be signed in"
	And I should be on the signin page
