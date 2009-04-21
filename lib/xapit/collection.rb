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
    
    def initialize(*args)
      @options = args.extract_options!
      @member_class = args[0]
      @search_text = args[1].to_s
      @query_parser = SimpleQueryParser.new(@member_class, @search_text, @options)
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
      fetch_results(0, 1).first
    end
    
    # The last record in the result set.
    def last
      fetch_results(size-1, 1).last
    end
    
    # Perform another search on this one, inheriting all options already passed.
    # See Xapit::Membership for search options.
    def search(keywords, options = {})
      collection = Collection.new(@member_class, keywords, options)
      collection.base_query = @query_parser.query
      collection
    end
    
    def base_query=(base_query)
      @query_parser.base_query = base_query
    end
    
    # The page number we are currently on.
    def current_page
      @query_parser.current_page
    end
    
    # How many records to display on each page, defaults to 20. Sets with :per_page option when performing search.
    def per_page
      @query_parser.per_page
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
      if @search_text.downcase.scan(/[a-z0-9]+/).all? { |term| Config.database.get_spelling_suggestion(term).empty? }
        nil
      else
        @search_text.downcase.gsub(/[a-z0-9]+/) do |term|
          Config.database.get_spelling_suggestion(term)
        end
      end
    end
    
    private
    
    def all_facets
      @member_class.xapit_index_blueprint.facets.map do |facet_blueprint|
        Facet.new(facet_blueprint, @query_parser.query, @query_parser.facet_identifiers)
      end
    end
    
    def matchset(offset = nil, limit = nil)
      @query_parser.query.matchset(offset || per_page*(current_page-1), limit || per_page, :sort_by_values => @query_parser.sort_by_values, :sort_descending => @options[:descending])
    end
    
    def fetch_results(offset = nil, limit = nil)
      matchset(offset, limit).matches.map do |match|
        class_name, id = match.document.data.split('-')
        member = class_name.constantize.find(id)
        member.xapit_relevance = match.percent
        member
      end
    end
  end
end
