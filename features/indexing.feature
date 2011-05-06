Feature: Indexing

  Scenario: Save xapian database on index
    Given no file exists at "tmp/testdb"
    And an empty database at "tmp/testdb"
    And 3 records
    When I index the database
    Then I should find a directory at "tmp/testdb"

  Scenario: Fetch all records which are indexed
    Given an empty database at "tmp/testdb"
    And records named "John, Jane, Joe"
    When I index the database
    And I query for ""
    Then I should find records named "John, Jane, Joe"

  Scenario: Index Multiple Field Values Separately
    Given an empty database at "tmp/testdb"
    And the following indexed records
      | name | age    |
      | John | 17, 16 |
      | Jack | 17     |
      | Jane | 16     |
    When I query "age" matching "16"
    Then I should find records named "Jane, John"

  Scenario: Index Weighted Attributes
    Given an empty database at "tmp/testdb"
    And the following indexed records with "name" weighted by "10"
      | name | description |
      | foo  | bar         |
      | bar  | foo         |
    When I query for "bar"
    Then I should find records named "bar, foo"
    When I query for "foo"
    Then I should find records named "foo, bar"

  # Scenario: Split indexed text fields differently
  #   Given an empty database at "tmp/testdb"
  #   And records named "JohnXSmith, JaneXSmith, JoeXBlack"
  #   When I index the database splitting name by "X"
  #   And I query for "Smith"
  #   Then I should find records named "JohnXSmith, JaneXSmith"
