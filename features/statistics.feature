@statistics

Feature: Statistics
    As a site administrator
    I want to be able to view some statistics for the site

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
	    | bob@example.com   |
        And "alice@example.com" is an activated user account
        And "bob@example.com" is an activated user account
        And "alice@example.com" can "view_statistics"


    Scenario: Get user statistics
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Statistics"
    	And I follow "User statistics"
        Then I should be on the user_statistics page

    Scenario: Get user statistics (not signed in)
    	When I go to the user_statistics page
    	Then I should see "You must be signed in"
    	And I should be on the signin page

    Scenario: Get user statistics (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
    	When I go to the user_statistics page
    	Then I should see "You are not allowed to do that"
    	And I should be on the my_page page


    Scenario: Get reminder email statistics
        When I signin as "alice@example.com" with password "P@55word"
    	And I follow "Statistics"
        And I follow "Reminder email statistics"
        Then I should be on the email_reminders_statistics page

    Scenario: Get reminder email statistics (not signed in)
    	When I go to the email_reminders_statistics page
    	Then I should see "You must be signed in"
    	And I should be on the signin page

    Scenario: Get reminder email statistics (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
    	When I go to the email_reminders_statistics page
    	Then I should see "You are not allowed to do that"
    	And I should be on the my_page page


    Scenario: Get automation tasks statistics
        When I signin as "alice@example.com" with password "P@55word"
    	And I follow "Statistics"
        And I follow "Automation task statistics"
        Then I should be on the automation_tasks_statistics page

    Scenario: Get automation tasks statistics (not signed in)
    	When I go to the automation_tasks_statistics page
    	Then I should see "You must be signed in"
    	And I should be on the signin page

    Scenario: Get automation tasks (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
    	When I go to the automation_tasks_statistics page
    	Then I should see "You are not allowed to do that"
    	And I should be on the my_page page