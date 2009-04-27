module Xapit
  # This is the object which is returned when performing a search. It behaves like an array, so you do not need
  # to worry about fetching the results separately. Just loop through this collection.
  # 
  # The results are lazy loading, meaning it does not perform the query on the database until it has to.
  # This allows you to string queries onto one another.
  #
  #   Article.search("kite").search("sky") # only performs one query
  #
  # This class is compatible with will_paginate; you can pass it to the will_paginate helper in the view.
  class Collection
    NON_DELEGATE_METHODS = %w(nil? send object_id class extend size paginate first last empty? respond_to?).to_set
    [].methods.each do |m|
      delegate m, :to => :results unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
    end
    
    def self.search_similar(member, *args)
      collection = new(member.class, *args)
      indexer = SimpleIndexer.new(member.class.xapit_index_blueprint)
      terms = indexer.text_terms(member) + indexer.field_terms(member)
      collection.base_query.and_query(Xapian::Query.new(Xapian::Query::OP_OR, terms))
      collection.base_query.not_query("Q#{member.class}-#{member.id}")
      collection
    end
    
    def initialize(*args)
      @query_parser = Config.query_parser.new(*args)
    end
    
    # Returns an array of results. You should not need to call this directly because most methods are 
    # automatically delegated to this array.
    def results
      @results ||= fetch_results
    end
    
    # The number of total records found despite any pagination settings.
    def size
      @query_parser.query.count
    end
    alias_method :total_entries, :size
    
    # Returns true if no results are found.
    def empty?
      @results ? @results.empty? : size.zero?
    end
    
    # The first record in the result set.
    def first
      fetch_results(:offset => 0, :limit => 1).first
    end
    
    # The last record in the result set.
    def last
      fetch_results(:offset => size-1, :limit => 1).last
    end
    
    # Perform another search on this one, inheriting all options already passed.
    # See Xapit::Membership for search options.
    def search(keywords, options = {})
      collection = Collection.new(@query_parser.member_class, keywords, options)
      collection.base_query = @query_parser.query
      collection
    end
    
    def base_query=(base_query)
      @query_parser.base_query = base_query
    end
    
    def base_query
      @query_parser.base_query
    end
    
    # The page number we are currently on.
    def current_page
      @query_parser.current_page
    end
    
    # How many records to display on each page, defaults to 20. Sets with :per_page option when performing search.
    def per_page
      @query_parser.per_page
    end
    
    # The offset for the current page
    def offset
      @query_parser.offset
    end
    
    # Total number of pages with found results.
    def total_pages
      (total_entries / per_page.to_f).ceil
    end
    
    # The previous page number. Returns nil if on first page.
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end
    
    # The next page number. Returns nil if on last page.
    def next_page
      current_page < total_pages ? (current_page + 1): nil
    end
    
    # Xapit::Facet objects matching this search query. See class for details.
    def facets
      all_facets.select do |facet|
        facet.options.size > 1
      end
    end
    
    # Xapit::FacetOption objects which are currently applied to search (through :facets option). Use this to
    # display the facets which are currently applied.
    #
    #   <% for option in @articles.applied_facet_options %>
    #     <%=h option.name %>
    #     <%= link_to "remove", :overwrite_params => { :facets => option }) %>
    #   <% end %>
    #
    def applied_facet_options
      @query_parser.facet_identifiers.map do |identifier|
        option = FacetOption.find(identifier)
        option.existing_facet_identifiers = @query_parser.facet_identifiers
        option
      end
    end
    
    # Includes a suggested variation of a term which will get many more results. Returns nil if no suggestion.
    # 
    #   <% if @articles.spelling_suggestion %>
    #     Did you mean <%= link_to h(@articles.spelling_suggestion), :overwrite_params => { :keywords => @articles.spelling_suggestion } %>?
    #   <% end %>
    # 
    def spelling_suggestion
      @query_parser.spelling_suggestion
    end
    
    private
    
    def all_facets
      @query_parser.member_class.xapit_index_blueprint.facets.map do |facet_blueprint|
        Facet.new(facet_blueprint, @query_parser.query, @query_parser.facet_identifiers)
      end
    end
    
    def matchset(options = {})
      @query_parser.query.matchset(options)
    end
    
    def fetch_results(options = {})
      matchset(options).matches.map do |match|
        class_name, id = match.document.data.split('-')
        member = class_name.constantize.find(id)
        member.xapit_relevance = match.percent
        member
      end
    end
  end
end
