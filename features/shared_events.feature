@shared_events
@shared_event
@shared_event_attendance
@shared_event_field
@shared_event_field_data


Feature: Site Announcements
    As an event organiser
    In order to run a good event
    I want to be able to get the information that I need about attendees

    As a section leader
    In order to nsave my time
    I want OSMX to communicate my attendee's data for me


    Background:
	Given I have no shared_events
	And I have no shared_event_attendances
	And I have no shared_event_fields
	And I have no shared_event_field_datas
        And I have no users
        And I have the following user records
	    | email_address     |
	    | alice@example.com |
        And "alice@example.com" is an activated user account
        And "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
            | flexi      | read    |
            | events     | write   |


    Scenario: Edit an event
        Given I have the following shared_event records
	    | name       | user_email_address |
	    | Event name | alice@example.com  |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Shared events (management)"
        And I follow "[Edit]" in the "Actions" column of the "Event name" row
        And I fill in "Name" with "Event name 2"
        And I press "Update Shared event"
        Then I should see "Event name 2 was successfully updated."


    Scenario: Attend an event
	Given an OSM request to get_flexi_record_fields for section "1" flexi "101" will have the fields
	    | id         | name       |
	    | firstname  | First name |
	    | lastname   | Last name  |
	    | f_01       | Custom 1   |
	Given an OSM request to get_flexi_record_fields for section "1" flexi "102" will have the fields
	    | id         | name       |
	    | firstname  | First name |
	    | lastname   | Last name  |
	    | f_01       | Custom 1 2 |
	And an OSM request to get terms for section 1 will have the term
	    | term_id | name   |
	    | 1       | Term 1 |
        Given I have the following shared_event records
	    | name       | user_email_address |
	    | Event name | alice@example.com  |
        And an OSM request to "create_event" will work
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the attend shared event "Event name" page
        And I press "Create Shared event attendance"
        Then I should see "Shared event attendance was successfully created."
