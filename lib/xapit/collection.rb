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
    
    def initialize(member_class, search_text, options = {})
      @member_class = member_class
      @search_text = search_text.to_s
      @options = options
    end
    
    # Returns an array of results. You should not need to call this directly because most methods are 
    # automatically delegated to this array.
    def results
      @results ||= fetch_results
    end
    
    # The number of total records found despite any pagination settings.
    def size
      query.count
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
      collection.base_query = query
      collection
    end
    
    def base_query=(base_query)
      @base_query = base_query
    end
    
    # The page number we are currently on.
    def current_page
      @options[:page] ? @options[:page].to_i : 1
    end
    
    # How many records to display on each page, defaults to 20. Sets with :per_page option when performing search.
    def per_page
      @options[:per_page] ? @options[:per_page].to_i : 20
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
      facet_identifiers.map do |identifier|
        option = FacetOption.find(identifier)
        option.existing_facet_identifiers = facet_identifiers
        option
      end
    end
    
    private
    
    def all_facets
      @member_class.xapit_index_blueprint.facets.map do |facet_blueprint|
        Facet.new(facet_blueprint, query, facet_identifiers)
      end
    end
    
    def matchset(offset = nil, limit = nil)
      query.matchset(offset || per_page*(current_page-1), limit || per_page)
    end
    
    def query
      if (search_terms + condition_terms + facet_terms).empty?
        base_query
      else
        @query ||= base_query.and_query(search_terms + condition_terms + facet_terms)
      end
    end
    
    def base_query
      @base_query || Query.new("C" + @member_class.name)
    end
    
    def fetch_results(offset = nil, limit = nil)
      matchset(offset, limit).matches.map do |match|
        member = @member_class.find(match.document.data.split('-').last)
        member.xapit_relevance = match.percent
        member
      end
    end
    
    def search_terms
      @search_text.split.map { |term| term.downcase }
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
    
    def facet_terms
      if @options[:facets]
        facet_identifiers.map do |identifier|
          "F#{identifier}"
        end
      else
        []
      end
    end
    
    def facet_identifiers
      @options[:facets].kind_of?(String) ? @options[:facets].split('-') : (@options[:facets] || [])
    end
  end
end
