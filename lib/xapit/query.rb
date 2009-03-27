module Xapit
  class Query # TODO make this class unmutable?
    def initialize(*words)
      @query = Xapian::Query.new(Xapian::Query::OP_AND, words.flatten)
    end
    
    def and_query(*words)
      add_query Xapian::Query.new(Xapian::Query::OP_AND, words.flatten)
    end
    
    def or_query(*words)
      add_query Xapian::Query.new(Xapian::Query::OP_OR, words.flatten)
    end
    
    def not_query(*words)
      add_negative_query Xapian::Query.new(Xapian::Query::OP_AND, words.flatten)
    end
    
    def matchset(offset, limit, options = {})
      enquire = Xapian::Enquire.new(Config.database)
      enquire.collapse_key = options[:collapse_key] if options[:collapse_key]
      enquire.query = @query
      enquire.mset(offset, limit)
    end
    
    def matches(offset, limit, options = {})
      matchset(offset, limit, options).matches
    end
    
    def count
      matchset(0, 1).matches_estimated
    end
    
    private
    
    def add_query(query)
      @query = Xapian::Query.new(Xapian::Query::OP_AND, @query, query)
      self
    end
    
    def add_negative_query(query)
      @query = Xapian::Query.new(Xapian::Query::OP_AND_NOT, @query, query)
      self
    end
  end
end
