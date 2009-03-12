module Xapit
  class Collection
    NON_DELEGATE_METHODS = %w(nil? send object_id class extend size paginate first last empty? respond_to?).to_set
    [].methods.each do |m|
      delegate m, :to => :results unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
    end
    
    def initialize(member_class, query, options = {})
      @member_class = member_class
      @query = query
      @options = options
    end
    
    def results
      @results ||= fetch_results(0, 20)
    end
    
    def size
      matchset(0, 1).matches_estimated
    end
    
    def empty?
      @results ? @results.empty? : size.zero?
    end
    
    def first
      fetch_results(0, 1).first
    end
    
    def last
      fetch_results(size-1, 1).last
    end
    
    private
    
    def matchset(offset, limit)
      enquire = Xapian::Enquire.new(database)
      enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, ["C" + @member_class.name, *(query_terms + condition_terms)])
      enquire.mset(offset, limit)
    end
    
    def fetch_results(offset, limit)
      matchset(offset, limit).matches.map do |match|
        @member_class.find(match.document.data.split('-').last)
      end
    end
    
    def query_terms
      @query.split.map { |term| term.downcase }
    end
    
    def condition_terms
      if @options[:conditions]
        @options[:conditions].map do |name, value|
          "X#{name}-#{value.downcase}"
        end
      else
        []
      end
    end
    
    def database
      # TODO fetch database from global config
      @options[:database]
    end
  end
end
