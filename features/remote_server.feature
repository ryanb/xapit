# Feature: Remote Server
# 
#   Background:
#     Given a remote database
# 
#   @focus
#   Scenario: Basic index and search
#     Given records named "John Smith, John Doe, Jane, Joe"
#     When I index the database
#     And I query for "John"
#     Then I should find records named "John Smith, John Doe"
