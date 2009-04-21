Background:
  Given an empty database at "tmp/xapiandatabase"

Scenario: One-word spelling suggestion
  Given indexed records named "Zebra, Apple"
  When I query for "zerba"
  Then I should have "zebra" as a spelling suggestion

@focus
Scenario: Multi-word spelling suggestion
  Given indexed records named "Zebra, Apple"
  When I query for "zerba aple"
  Then I should have "zebra apple" as a spelling suggestion
