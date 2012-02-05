@email_lists
@osm

Feature: Email Lists
    As a section leader
    In order to keep in touch with members of the section
    I want to be able to retreieve a list of email addresses

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account
	And "alice@example.com" is connected to OSM
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
	And an OSM request to get members for section 1 in term 1 will have the members
	    | email1         | email2         | email3         | email4         | grouping_id |
	    | a1@example.com | a2@example.com | a3@example.com | a4@example.com | 1           |
	    | b1@example.com | b2@example.com | b3@example.com | b4@example.com | 2           |
	And an OSM request to get groupings for section 1 will have the groupings
	    | grouping_id | name |
	    | 1           | A    |
	    | 2           | B    |
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get sections will give 1 section

    Scenario: Get list of addresses (are in a six)
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Email lists"
        Then I should be on the generate_email_list page
        When I check "email1"
        And I check "email2"
        And I select "are" from "match_type"
        And I select "A" from "match_grouping"
        And I press "Submit"
        Then I should see "a1@example.com"
        And I should see "a2@example.com"
        And I should not see "a3@example.com"
        And I should not see "a4@example.com"
        And I should not see "b1@example.com"
        And I should not see "b2@example.com"
        And I should not see "b3@example.com"
        And I should not see "b4@example.com"

    Scenario: Get list of addresses (are not in a six)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the generate_email_list page
        When I check "email3"
        And I check "email4"
        And I select "are not" from "match_type"
        And I select "A" from "match_grouping"
        And I press "Submit"
        Then I should not see "a1@example.com"
        And I should not see "a2@example.com"
        And I should not see "a3@example.com"
        And I should not see "a4@example.com"
        And I should not see "b1@example.com"
        And I should not see "b2@example.com"
        And I should see "b3@example.com"
        And I should see "b4@example.com"

    Scenario: Get list of addresses (everyone)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the generate_email_list page
        When I check "email1"
        And I check "email2"
        And I check "email3"
        And I check "email4"
        And I select "are" from "match_type"
        And I select "Any" from "match_grouping"
        And I press "Submit"
        Then I should see "a1@example.com"
        And I should see "a2@example.com"
        And I should see "a3@example.com"
        And I should see "a4@example.com"
        And I should see "b1@example.com"
        And I should see "b2@example.com"
        And I should see "b3@example.com"
        And I should see "b4@example.com"

    Scenario: Get list of addresses (not everyone)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the generate_email_list page
        When I check "email1"
        And I check "email2"
        And I check "email3"
        And I check "email4"
        And I select "are not" from "match_type"
        And I select "Any" from "match_grouping"
        And I press "Submit"
        Then I should not see "a1@example.com"
        And I should not see "a2@example.com"
        And I should not see "a3@example.com"
        And I should not see "a4@example.com"
        And I should not see "b1@example.com"
        And I should not see "b2@example.com"
        And I should not see "b3@example.com"
        And I should not see "b4@example.com"
