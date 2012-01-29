@faq

Feature: FAQ Administration
    As an administrator of the site
    In order to help the users use it
    I want to be able to provide some FAQs

    As a user of the site
    In order to use it wihout trouble
    I want to be able to get some simple help before using the contact form


    Background:
	Given I have no users
        And I have no FAQs
        And I have the following user records
	    | email_address     | name  |
	    | alice@example.com | Alice |
	    | bob@example.com   | Bob |
        And I have the following faq records
	    | question | answer            | active |
            | FAQ 1    | This is answer 1. | true   |
            | FAQ 2    | This is answer 2. | false  |
        And "alice@example.com" is an activated user account
        And "bob@example.com" is an activated user account
        And "alice@example.com" can "administer_faqs"


    Scenario: View FAQs
        When I go to the root page
        And I follow "Help"
        Then I should see "FAQ 1"
        And I should not see "FAQ 2"

    Scenario: View FAQs (signed in as non FAQ administrator)
        When I signin as "bob@example.com" with password "P@55word"
        Then I should not see "Administer FAQs"
        And I follow "Help"
        Then I should see "FAQ 1"
        And I should not see "FAQ 2"

    Scenario: View FAQs (signed in as FAQ administrator)
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer FAQs"
        Then I should see "FAQ 1"
        And I should see "FAQ 2"
        When I follow "Help"
        Then I should see "FAQ 1"
        And I should not see "FAQ 2"


    Scenario: Edit FAQ
        When I signin as "alice@example.com" with password "P@55word"
        And I go to the list of faqs
	And I follow "[Edit]" in the "Actions" column of the "FAQ 1" row
        And I fill in "Question" with "FAQ 1A"
        And I fill in "Answer" with "This is answer 1A."
        And I press "Submit"
        Then I should see "FAQ was successfully updated"

    Scenario: Edit FAQ (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
        When I go to edit the FAQ "FAQ 1"
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: Edit FAQ (not signed in)
        When I go to edit the FAQ "FAQ 1"
	Then I should see "You must be signed in"
	And I should be on the signin page


    Scenario: Create FAQ
        When I signin as "alice@example.com" with password "P@55word"
        And I follow "Administer FAQs"
        And I fill in "Question" with "FAQ 3"
        And I fill in "Answer" with "This is answer 3"
        And I check "Active"
        And I press "Submit"
        Then I should see "FAQ was successfully created"
        And I should have 3 FAQs

    Scenario: Create FAQ (not authorised)
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the new faq page
        Then I should see "You are not authorised to do that."
	And I should be on the root page

    Scenario: Create FAQ (not signed in)
        When I go to the new faq page
	Then I should see "You must be signed in"
	And I should be on the signin page
