Background:
  Given an empty database at "tmp/xapiandatabase"

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

Scenario: Query Field Matching
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query "age" matching "17"
  Then I should find records named "Jane, Jack"

Scenario: Query for Page 1
  Given 3 indexed records
  When I query page 1 at 2 per page
  Then I should find 2 records

Scenario: Query for Page 2
  Given 3 indexed records
  When I query page 2 at 2 per page
  Then I should find 1 record
  And I should have 3 records total

Scenario: Query for All Records Class Agnostic
  Given indexed records named "John, Jane"
  When I query for "John" on Xapit
  Then I should find 1 record

Scenario: Query Matching Or Query
  Given indexed records named "John, Jane, Jacob"
  When I query for "Jane OR John"
  Then I should find records named "John, Jane"

Scenario: Query Matching Not Query
  Given indexed records named "John Smith, John Johnson"
  When I query for "John NOT Smith"
  Then I should find records named "John Johnson"

Scenario: Unicode characters in search
  Given indexed records named "über cool, uber hot"
  When I query for "über"
  Then I should find records named "über cool"

Scenario: Query Field Not Matching
  Given the following indexed records
    | name | age |
    | John | 23  |
    | Jane | 17  |
    | Jack | 17  |
  When I query "age" not matching "17"
  Then I should find records named "John"

Scenario: Query Range of Integer
  Given the following indexed records
    | name | age |
    | John | 8   |
    | Jane | 13  |
    | Jack | 24  |
  When I query "age" between 8 and 15
  Then I should find records named "John, Jane"

Scenario: Query Partial Match on Condition
  Given the following indexed records
    | name | sirname  |
    | John | Jacobson |
    | Jane | Niel     |
    | Jack | Striker  |
  When I query "name" matching "Ja*"
  Then I should find records named "Jane, Jack"

Scenario: Query no partial match on conditions with one letter
  Given the following indexed records
    | name | sirname  |
    | John | Jacobson |
    | Jane | Niel     |
    | Jack | Striker  |
  When I query "name" matching "J*"
  Then I should find 0 records
