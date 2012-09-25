Feature: Finding

  Scenario: Query Matching No Records
    Given indexed records named "John, Jane"
    When I query for "Sam"
    Then I should find 0 records

  Scenario: Query Matching One Record
    Given indexed records named "John, Jane"
    When I query for "John"
    Then I should find record named "John"

  Scenario: Query Matching Two Records
    Given indexed records named "John Smith, Jane Smith, John Smithsonian"
    When I query for "Smith"
    Then I should find records named "John Smith, Jane Smith"

  Scenario: Query for All Records Class Agnostic
    Given indexed records named "John, Jane"
    When I query for "John" on Xapit
    Then I should find 1 record

  Scenario: Query Field Matching
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query "age" matching "17"
    Then I should find records named "Jane, Jack"

  Scenario: Query Text and Field Matching
    Given the following indexed records
      | name | age |
      | Jane | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query for "Jane" and "age" matching "17"
    Then I should find records named "Jane"

  Scenario: Query Field Not Matching
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query "age" not matching "17"
    Then I should find records named "John"

  Scenario: Query for separate OR conditions
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 18  |
    When I query "age" matching "17" or "name" matching "Jack"
    Then I should find records named "Jane, Jack"

  Scenario: Query Matching Or Query
    Given indexed records named "John, Jane, Jacob"
    When I query for "Jane OR John"
    Then I should find records named "John, Jane"
    When I query for "Jane" or "John"
    Then I should find records named "Jane, John"

  Scenario: Query Matching Not Query
    Given indexed records named "John Smith, John Johnson"
    When I query for "John NOT Smith"
    Then I should find records named "John Johnson"
    When I query for "John" not "Smith"
    Then I should find records named "John Johnson"

  Scenario: Unicode characters in search
    Given indexed records named "über cool, uber hot"
    When I query for "über"
    Then I should find records named "über cool"

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

  Scenario: Query for Page 1
    Given 3 indexed records
    When I query page 1 at 2 per page
    Then I should find 2 records

  Scenario: Query for Page 2
    Given 3 indexed records
    When I query page 2 at 2 per page
    Then I should find 1 record
    And I should have 3 records total

  Scenario: Query Range of Integer
    Given the following indexed records
      | name | age |
      | John | 8   |
      | Jane | 13  |
      | Jack | 24  |
    When I query "age" between 8 and 15
    Then I should find records named "John, Jane"

  Scenario: Query for condition in keywords string
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query for "age:17"
    Then I should find records named "Jane, Jack"

  Scenario: Query for separate OR conditions and keywords
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 18  |
    When I query for "John" or "age" matching "18" ordered by "name"
    Then I should find records named "Jack, John"


  Scenario: Query partial match in keywords
    Given the following indexed records
      | name | sirname  |
      | John | Jacobson |
      | Bill | Niel     |
      | Jack | Striker  |
    When I query for "Ja*"
    Then I should find records named "John, Jack"

  Scenario: Query no partial match in keywords with one letter
    Given the following indexed records
      | name | sirname  |
      | John | Jacobson |
      | Bill | Niel     |
      | Jack | J        |
    When I query for "J*"
    Then I should find records named "Jack"

  Scenario: Query no stemming
    Given indexed records named "runs, sat, sits"
    And no stemming
    When I query for "run"
    Then I should find 0 records

  Scenario: Query with stemming by default
    Given indexed records named "runs, sat, sits"
    When I query for "run"
    Then I should find records named "runs"

  Scenario: Query ignore punctuation in keyword
    Given the following indexed records
      | name | sirname    |
      | Jack | John-son's |
      | Bill | Johnsons   |
      | Jane | Johnson    |
    When I query for "Johnsons"
    Then I should find records named "Jack, Bill"
    When I query for "Jo-hn'sons"
    Then I should find records named "Jack, Bill"

  Scenario: Query with minimum relevance percent
    Given the following indexed records with "name" weighted by "10"
      | name | description |
      | Jim  | foo         |
      | Bob  | bar         |
      | Rus  | Bob         |
    When I query for "Bob" with minimum relevance of "50%"
    Then I should find records named "Bob"
    When I query for "Bob" with minimum relevance of "25%"
    Then I should find records named "Bob, Rus"

  # Scenario: Query Partial Match on Condition
  #   Given the following indexed records
  #     | name | sirname  |
  #     | John | Jacobson |
  #     | Jane | Niel     |
  #     | Jack | Striker  |
  #   When I query "name" matching "Ja*"
  #   Then I should find records named "Jane, Jack"
  #
  # Scenario: Query no partial match on conditions with one letter
  #   Given the following indexed records
  #     | name | sirname  |
  #     | John | Jacobson |
  #     | Jane | Niel     |
  #     | Jack | Striker  |
  #   When I query "name" matching " J*"
  #   Then I should find 0 records
