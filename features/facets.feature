Feature: Facets

  Background:
    Given an empty database at "tmp/testdb"

  Scenario: List All Facets
    Given the following indexed records
      | name | age |
      | John | 23  |
      | John | 17  |
      | Jack | 17  |
    When I query for ""
    Then I should have the following facets
      | facet | option | count |
      | Name  | Jack   | 1     |
      | Name  | John   | 2     |
      | Age   | 17     | 2     |
      | Age   | 23     | 1     |

  Scenario: List Matching Facets
    Given the following indexed records
      | name | age |
      | John | 23  |
      | John | 17  |
      | Jack | 17  |
    When I query for "John"
    Then I should have the following facets
      | facet | option | count |
      | Age   | 17     | 1     |
      | Age   | 23     | 1     |

  Scenario: List Multiple Facets Applied to One Record
    Given the following indexed records
      | name       |
      | John, Jack |
      | John       |
      | Joe, Jack  |
    When I query for ""
    Then I should have the following facets
      | facet | option | count |
      | Name  | Jack   | 2     |
      | Name  | Joe    | 1     |
      | Name  | John   | 2     |

  Scenario: Ignore Facets That Do Not Narrow Down List
    Given the following indexed records
      | name       |
      | John, Jack |
      | John       |
    When I query for ""
    Then I should have the following facets
      | facet | option | count |
      | Name  | Jack   | 1     |

  Scenario: Query for One Facet
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query facets "9f33345"
    Then I should find records named "Jane, Jack"

  Scenario: Query for Two Facets
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query facets "9f33345-9a10ff2"
    Then I should find records named "Jane"

  Scenario: Query for Facets with Keywords
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query "Jane" with facets "9f33345"
    Then I should find record named "Jane"

  Scenario: List Applied Facets
    Given the following indexed records
      | name | age |
      | John | 23  |
      | Jane | 17  |
      | Jack | 17  |
    When I query facets "0c93ee1-078661c"
    Then I should have the following applied facets
      | facet | option |
      | Age   | 17     |
      | Name  | Jane   |
