Feature: Suggestions

  # Background:
  #   Given an empty database at "tmp/testdb"
  # 
  # Scenario: Spelling suggestion
  #   Given indexed records named "Zebra, Apple, Bike"
  #   When I query for "zerba bike aple"
  #   Then I should have "zebra bike apple" as a spelling suggestion
  # 
  # Scenario: Match similar words with stemming
  #   Given indexed records named "flies, fly, glider"
  #   When I query for "flying"
  #   Then I should find records named "flies, fly"
  # 
  # Scenario: Find similar records
  #   Given indexed records named "Jason John Smith, John Doe, Jason Smith, Jacob Johnson"
  #   When I query for similar records for "Jason John Smith"
  #   Then I should find records named "Jason Smith, John Doe"
