Feature: Nil Layout
  As a hacker who likes to render unstyled pages
  I want to be able to render some pages without a layout
  In order to make the pages stand on their own

  Scenario: Use custom layout data
    Given I have a _layouts directory
    And I have a "_layouts/nil.html" file with content:
      """
      {{ content }} scrambler from the nil layout
      """
    And I have an "index.md" page with layout "nil" that contains "page content"
    When I run jekyll build
    Then the "_site/index.html" file should exist
    And I should not see "scrambler from the nil layout" in "_site/index.html"
