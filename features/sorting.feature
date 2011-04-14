Feature: Sorting

  Background:
    Given an empty database at "tmp/testdb"

  Scenario: Query for All Records Sorted by Name
    Given indexed records named "Zebra, Apple, Banana"
    When I query "" sorted by name
    Then I should find records named "Apple, Banana, Zebra"

  Scenario: Query for All Records Sorted by Age then Name
    Given the following indexed records
      | name   | age |
      | Banana | 23  |
      | Zebra  | 17  |
      | Apple  | 17  |
    When I query "" sorted by age, name
    Then I should find records named "Apple, Zebra, Banana"

  Scenario: Query for All Records Sorted by Name Descending
    Given indexed records named "Zebra, Apple, Banana"
    When I query "" sorted by name descending
    Then I should find records named "Zebra, Banana, Apple"

  Scenario: Query for Records Sorted Numerically
    Given the following indexed records
      | name   | age |
      | Banana | 9   |
      | Zebra  | 10  |
    When I query "" sorted by age, name
    Then I should find records named "Banana, Zebra"
