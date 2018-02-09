Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to display course title, course date and the
  participants name on the certificate


  Scenario: Generate certificates
    Given the delivery for the course "Coding As A Craft" is set to "2016-09-16"
    And the data file for "2016-09-16" is imported
    And I am on 2016-09-16 show page
    And I click "Generate certificates" link
    And I should see 4 "view certificate" links

  Scenario: Certificate generation is disabled if certificates exists
    Given valid certificates exists
    Then I should not see "Generate certificates"
