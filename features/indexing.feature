Scenario: Save xapian database on index
  Given I configured the database to be saved at "tmp/xapiandb"
  And I have a class to be indexed
  And I have 3 records
  When I index the database
  Then I should find a directory at "tmp/xapiandb"
