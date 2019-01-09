@user

Feature: GDPR Consent
    As a site administrator
    In order to better coply eith the GDPR
    I want to know all existing users have given positive informed consent


    Background:
        Given I have no users
        And I have the following user records
            | email_address     | gdpr_consent_at         |
            | alice@example.com | 2018-01-01 00:00:00 UTC |
            | bob@example.com   |                         |
        And "alice@example.com" is an activated user account
        And "bob@example.com" is an activated user account
        Then "alice@example.com" should have granted GDPR consent
        And "bob@example.com" should not have granted GDPR consent


    Scenario: Redirect after signin (user has previously given consent)
        When I signin as "alice@example.com" with password "P@55word"
        Then I should see "Successfully signed in."
      	And I should be on the my_page page


    Scenario: Get consent after signin
        When I signin as "bob@example.com" with password "P@55word"
        Then I should see "Successfully signed in."
      	And I should be on the gdpr_consent page

    Scenario: Get consent when visiting any page requiring signin
        When I signin as "bob@example.com" with password "P@55word"
        Then I should see "Successfully signed in."

        When I go to the my_account page
      	Then I should be on the gdpr_consent page

        When I go to the my_page page
      	Then I should be on the gdpr_consent page

        When I go to the email_lists page
      	Then I should be on the gdpr_consent page

        When I go to the osm_flexi_records page
      	Then I should be on the gdpr_consent page

        When I go to the osm_search_members_form page
      	Then I should be on the gdpr_consent page

        When I go to the osm_myscout_payments_calculator page
      	Then I should be on the gdpr_consent page

        When I go to the check_osm_setup page
      	Then I should be on the gdpr_consent page

        When I go to the programme_review_balanced page
      	Then I should be on the gdpr_consent page

        When I go to the osm_exports page
      	Then I should be on the gdpr_consent page

        When I go to the reports page
      	Then I should be on the gdpr_consent page

        When I go to the automation_tasks page
      	Then I should be on the gdpr_consent page


    Scenario: Don't get consent when visiting any page not requiring signin
        When I signin as "bob@example.com" with password "P@55word"
        Then I should see "Successfully signed in."

        When I go to the contact_us page
      	Then I should be on the contact_us page

        When I go to the privacy_policy page
      	Then I should be on the privacy_policy page



    Scenario: Giving consent
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the gdpr_consent page
    		And I check "gdpr_consent"
        And I press "Give consent"
        Then I should be on the my_page page
        And I should see "Thank you, your consent has been recorded."
        And "bob@example.com" should have granted GDPR consent

    Scenario: Giving consent (didn't tick box)
        When I signin as "bob@example.com" with password "P@55word"
        And I go to the gdpr_consent page
        And I press "Give consent"
        Then I should be on the gdpr_consent page
        And I should see "You must check the box to give consent."
        And "bob@example.com" should not have granted GDPR consent
