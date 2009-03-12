module Xapit
  class Collection
    NON_DELEGATE_METHODS = %w(nil? send object_id class extend find size count sum average maximum minimum paginate first last empty? any? respond_to?).to_set
    [].methods.each do |m|
      delegate m, :to => :results unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
    end
    
    def initialize(member_class, query, options = {})
      @member_class = member_class
      @query = query
      @options = options
    end
    
    def results
      @results ||= fetch_results
    end
    
    def size
      matchset.matches_estimated
    end
    
    private
    
    def matchset
      if @matchset
        @matchset
      else
        enquire = Xapian::Enquire.new(database)
        enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, ["C" + @member_class.name, *(query_terms + condition_terms)])
        @matchset = enquire.mset(0, 20)
      end
    end
    
    def fetch_results
      matchset.matches.map do |match|
        @member_class.find(match.document.data.split('-').last)
      end
    end
    
    def query_terms
      @query.split.map { |term| term.downcase }
    end
    
    def condition_terms
      if @options[:conditions]
        @options[:conditions].map do |name, value|
          "X#{name}-#{value}"
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
