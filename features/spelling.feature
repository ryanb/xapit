Background:
  Given an empty database at "tmp/xapiandatabase"

@focus
Scenario: One word spelling suggestion
  Given indexed records named "Zebra, Apple"
  When I query for "zerba"
  Then I should have "zebra" as a spelling suggestion
