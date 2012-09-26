@announcement

Feature: Site Announcements
    As an administrator of the site
    In order to keep the users upto date about important things
    I want to be able to set a number of site announcements to be displayed
    And I want to be able to email the really important ones to site users

    As a user of the site
    In order to not be bothered with the same announcement
    I want to be able to hide each one


    Background:
	Given I have no users
        And I have no announcements
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
	    | bob@example.com   | Bob   |
        And I have the following announcement records
	    | message                  | public  | prevent_hiding |
            | Public announcement      | true    | false          |
            | Member announcement 1    | false   | false          |
            | Member announcement 2    | false   | false          |
            | Non-hideable annoucement | false   | true           |
        And "alice@example.com" is an activated user account
        And "bob@example.com" is an activated user account
        And "alice@example.com" can "administer_announcements"


    Scenario: See announcements displayed
        When I go to the root page
        Then I should see "Public announcement"
        And I should not see "Member announcement 1"
        And I should not see "Member announcement 2"
        And I should not see "Non-hideable annoucement"
        And I should not see "Hide this announcement"

        When I signin as "bob@example.com" with password "P@55word"
        Then I should see "Public announcement"
        And I should see "Member announcement 1"
        And I should see "Member announcement 2"
        And I should see "Non-hideable annoucement"


    Scenario: View announcements (signed in as announcement administrator)
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer site announcements"
        Then I should see "Public announcement"
        And I should see "Member announcement 1"
        And I should see "Member announcement 2"
        And I should see "Non-hideable annoucement"

    Scenario: View announcements (not administrator)
        When I signin as "bob@example.com" with password "P@55word"
        Then I should not see "Administer site announcements"
        When I go to the list of announcements
        Then I should see "You are not authorised to do that."
	And I should be on the my_page page


    Scenario: Create announcement
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer site announcements"
        And I fill in "Message" with "Test"
        And I check "Public"
        And I check "Prevent hiding"
        And I press "Create Announcement"

        Then I should see "Announcement was successfully created."
        And I should not see "Emailing the announcement has been added to the job queue."
        And I should see "yes" in the "Current" column of the "Test" row
        And I should see "YES" in the "Public" column of the "Test" row
        And I should see "YES" in the "Prevent hiding" column of the "Test" row
        And I should not see "ago" in the "Emailed" column of the "Test" row

        And "alice@example.com" should receive no email with subject /Announcement/
        And "bob@example.com" should receive no email with subject /Announcement/

    Scenario: Create announcement (emailing users)
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer site announcements"
        And I fill in "Message" with "Test"
        And I check "Email to users"
        And I press "Create Announcement"

        Then I should see "Announcement was successfully created."
        And I should see "Emailing the announcement has been added to the job queue."
        And I should see "ago" in the "Emailed" column of the "Test" row

        And "alice@example.com" should receive an email with subject /Announcement/
        And "bob@example.com" should receive an email with subject /Announcement/
