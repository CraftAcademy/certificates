Feature: As an employee of an education institution
  In order to access all features of the application
  I would like to be given access by creating an administration account

  Scenario: Log in to the application
    Given I am a registered user
    Given I am on the home page
    And I click "Log in" link
    Then I should be on Log in page
    And I fill in "Email" with "thomas@random.com"
    And I fill in "Password" with "my_password"
    And I click "Submit" link
    Then I should be on the home page
    And I should see "Successfully logged in Thomas"
    And I should not see "Register"

  Scenario: Log out from the application
    Given I am a registered and logged in user
    And I click "Log out" link
    Then I should be on the home page
    And I should see "Successfully logged out"
