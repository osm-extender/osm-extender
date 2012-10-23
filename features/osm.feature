@my_account
@osm

Feature: OSM
    As a user of the site
    In order to use the site
    I want to be able to access my data on OSM

    Background:
	Given I have no users
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
        And "alice@example.com" is an activated user account


    Scenario: Connect to OSM Account
        Given an OSM request to "authorize" will work
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "You need to connect your account to your OSM account."
        And I should see "You have not yet connected your account to your OSM account"
        When I follow "Connect now"
        Then I should be on the connect_to_osm page
        When I fill in "Email" with "alice@example.com"
        And I fill in "Password" with "password"
        And I press "Connect to OSM"
        Then I should be on the osm_permissions page
        And I should see "Sucessfully connected to your OSM account"
	And I should see "Please use OSM to allow us access to your data"
        And "alice@example.com" should be connected to OSM

    Scenario: Connect to OSM Account (API Error)
        Given an OSM request to "authorize" will not work
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the connect_to_osm page
        And I fill in "Email" with "alice@example.com"
        And I fill in "Password" with "password"
        And I press "Connect to OSM"
        Then I should not see "Sucessfully connected to your OSM account."
	And I should see "We're sorry, an OSM error occured"
        And I should see "A simulated OSM API error occured"
        And "alice@example.com" should not be connected to OSM


    Scenario: Select between multiple OSM accounts
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 2 roles
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	And an OSM request to get_api_access for section "2" will have the permissions
	    | permission | granted |
	    | member     | read    |
        When I signin as "alice@example.com" with password "P@55word"
	Then I should see "Current section: Section 1 (1st Somewhere)"
	And I should see "Change Current Section"
	When I follow "1st Somewhere : Section 2"
	Then I should see "Current section: Section 2 (1st Somewhere)"

    Scenario: Select between single OSM account
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
        When I signin as "alice@example.com" with password "P@55word"
	Then I should see "Current section: Section 1 (1st Somewhere)"
	And I should not see "Change Current Section"


    Scenario: View OSM Permissions
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "OSM permissions"
        Then I should be on the osm_permissions page
	And the "Granted" column of the "Email lists" row I should see "yes"
	And the "Granted" column of the "Programme review" row I should see "NO"

    Scenario: View OSM Permissions (not connected to OSM)
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the osm_permissions page
	Then I should see "You must connect to your OSM account first"
	And I should be on the connect_to_osm page


    Scenario: View OSM Permissions (not signed in)
        When I go to the osm permissions page
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: No links or message for non signed in user
	When I go to the root page
	Then I should not see "links to things you can do will appear here"
	And I should not see "Email reminders"
	And I should not see "Programme review"
	And I should not see "Programme wizard"
	And I should not see "Email lists"
	And I should not see "OSM permissions"
	And I should not see "Map members"

    Scenario: Message but no links for non connected user
        When I signin as "alice@example.com" with password "P@55word"
	Then I should see "Email reminders"
	And I should not see "Email lists"
	And I should see "links to more things you can do will appear here"
	And I should not see "Map members"
	And I should not see "Programme review"
	And I should not see "Programme wizard"
	And I should not see "OSM permissions"

    Scenario: Links for connected user
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	    | programme  | write   |
        When I signin as "alice@example.com" with password "P@55word"
	Then I should not see "links to things you can do will appear here"
	And I should see "Email reminders"
	And I should see "Programme review"
	And I should see "Programme wizard"
	And I should see "Email lists"
	And I should see "OSM permissions"
	And I should see "Map members"

    Scenario: Message and selected links for connected user without permissions
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | none    |
        When I signin as "alice@example.com" with password "P@55word"
	Then I should see "Some items have hidden from this menu"
	And I should see "Email reminders"
	And I should see "Email lists"
	And I should see "OSM permissions"
	And I should not see "Programme review"
	And I should not see "Programme wizard"


    Scenario: No message and selected links for non youth section
	Given "alice@example.com" is connected to OSM
	And an OSM request to "get roles" will give 1 adult role
	And an OSM request to get_api_access for section "1" will have the permissions
	    | permission | granted |
	    | member     | read    |
	    | programme  | write   |
	    | flexi      | read    |
        When I signin as "alice@example.com" with password "P@55word"
	Then I should not see "Some items have hidden from this menu"
	And I should see "Email reminders"
	And I should see "Email lists"
	And I should see "OSM permissions"
	And I should not see "Programme review"
	And I should not see "Programme wizard"
