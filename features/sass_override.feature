Feature: Writing themes
  As a hacker who likes to have things my way
  I want to be able to customize a gemified theme
  In order to be in sync with my brand

  Scenario: A theme with SASS partials
    Given I have a configuration file with "theme" set to "test-theme"
    And I have an assets directory
    And I have an "assets/test.scss" file with content:
      """
      ---
      ---
      @import 'override';
      """
    When I run jekyll build
    Then I should get a zero exit status
    And the _site directory should exist
    And I should see ".sample {\n  color: red; }" in "_site/assets/test.css"

  Scenario: Override just a theme SASS partial
    Given I have a configuration file with "theme" set to "test-theme"
    And I have an assets directory
    And I have an "assets/test.scss" file with content:
      """
      ---
      ---
      @import 'override';
      """
    And I have a _sass/override directory
    And I have a "_sass/override/_test.scss" file with content:
      """
      .sample {
        color: black;
      }
      """
    When I run jekyll build
    Then I should get a zero exit status
    And the _site directory should exist
    And I should see ".sample {\n  color: black; }" in "_site/assets/test.css"

  Scenario: Override an 'imported' theme SASS partial
    Given I have a configuration file with "theme" set to "test-theme"
    And I have an assets directory
    And I have an "assets/test.scss" file with content:
      """
      ---
      ---
      @import 'override';
      """
    And I have a _sass/override directory
    And I have a "_sass/override.scss" file that contains "@import 'override/test';"
    And I have a "_sass/override/_test.scss" file with content:
      """
      .sample {
        color: black;
      }
      """
    When I run jekyll build
    Then I should get a zero exit status
    And the _site directory should exist
    And I should see ".sample {\n  color: black; }" in "_site/assets/test.css"
