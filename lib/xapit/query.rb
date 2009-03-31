module Xapit
  # This class is only used internally to make it more convenient for querying the xapian database.
  # You may be looking for Xapit::Collection instead.
  class Query # TODO make this class unmutable?
    attr_reader :parsed
    
    def initialize(text)
      @parsed = parse(text)
    end
    
    # REFACTORME this is a bit complex for one method...
    def xapian_query(instructions = nil)
      instructions ||= @parsed.dup
      instructions = [:add, instructions] if instructions.kind_of? String
      operator = (instructions.shift == :and ? Xapian::Query::OP_AND : Xapian::Query::OP_OR)
      words = instructions.select { |i| i.kind_of? String }
      query = Xapian::Query.new(operator, words)
      instructions.select { |i| i.kind_of? Array }.each do |sub_instructions|
        query = Xapian::Query.new(operator, query, xapian_query(sub_instructions))
      end
      query
    end
    
    def and_query(text)
      @parsed = [:and, @parsed, parse(text)] unless text.empty?
      self
    end
    
    def or_query(text)
      @parsed = [:or, @parsed, parse(text)] unless text.empty?
      self
    end
    
    def matchset(offset, limit, options = {})
      enquire = Xapian::Enquire.new(Config.database)
      enquire.collapse_key = options[:collapse_key] if options[:collapse_key]
      enquire.query = xapian_query
      enquire.mset(offset, limit)
    end
    
    def matches(offset, limit, options = {})
      matchset(offset, limit, options).matches
    end
    
    def count
      matchset(0, 1).matches_estimated
    end
    
    private
    
    def parse(text)
      if text.kind_of? Array
        [:and, *text]
      else
        text = text.strip
        if text =~ /\sor\s/i
          [:or, *text.split(/\s+or\s+/i).map { |t| parse(t) }]
        elsif text =~ /\s+/
          [:and, *text.split(' ')]
        else
          text
        end
      end
    end
  end
end
