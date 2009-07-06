module Xapit
  class AbstractQueryParser
    attr_reader :member_class
    attr_writer :base_query
    
    def initialize(*args)
      @options = args.extract_options!
      @member_class = args[0]
      @search_text = args[1].to_s
    end
    
    def query
      if (@search_text.split + condition_terms + not_condition_terms + facet_terms).empty?
        base_query
      else
        @query ||= base_query.and_query(xapian_query_from_text(@search_text)).and_query(condition_terms + facet_terms).not_query(not_condition_terms)
      end
    end
    
    def current_page
      @options[:page] ? @options[:page].to_i : 1
    end
    
    def per_page
      @options[:per_page] ? @options[:per_page].to_i : 20
    end
    
    def offset
      per_page*(current_page-1)
    end
    
    def sort_by_values
      if @options[:order] && @member_class
        index = @member_class.xapit_index_blueprint
        if @options[:order].kind_of? Array
          @options[:order].map do |attribute|
            index.position_of_sortable(attribute)
          end
        else
          [index.position_of_sortable(@options[:order])]
        end
      end
    end
    
    def base_query
      @base_query ||= initial_query
    end
    
    def initial_query
      query = Query.new(initial_query_strings, :or)
      query.default_options[:offset] = offset
      query.default_options[:limit] = per_page
      query.default_options[:sort_by_values] = sort_by_values
      query.default_options[:sort_descending] = @options[:descending]
      query
    end
    
    def initial_query_strings
      if classes.empty?
        [""]
      else
        classes.map { |klass| "C#{klass.name}" }
      end
    end
    
    def classes
      (@options[:classes] || [@member_class]).compact
    end
    
    def condition_terms
      parse_conditions(@options[:conditions])
    end
    
    def not_condition_terms
      parse_conditions(@options[:not_conditions])
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
    
    def spelling_suggestion
      raise "Spelling has been disabled. Enable spelling in Xapit.setup." unless Config.spelling?
      if [@search_text, *@search_text.scan(/\w+/)].all? { |term| term_suggestion(term).nil? }
        nil
      else
        return term_suggestion(@search_text) unless term_suggestion(@search_text).blank?
        @search_text.downcase.gsub(/\w+/) do |term|
          term_suggestion(term) || term
        end
      end
    end
    
    def term_suggestion(term)
      suggestion = Config.database.get_spelling_suggestion(term.downcase)
      suggestion.blank? ? nil : suggestion
    end
    
    private
    
    def parse_conditions(conditions)
      if conditions.kind_of? Array
        [Query.new(conditions.map { |hash| Query.new(condition_terms_from_hash(hash)) }, :or)]
      elsif conditions.kind_of? Hash
        condition_terms_from_hash(conditions)
      else
        []
      end
    end
    
    def condition_terms_from_hash(conditions)
      conditions.map do |name, value|
        if value.kind_of? Array
          Query.new(value.map { |v| condition_term(name, v) }, :or)
        else
          condition_term(name, value)
        end
      end.flatten
    end
    
    def condition_term(name, value)
      if value.kind_of?(Range) && @member_class
        position = @member_class.xapit_index_blueprint.position_of_field(name)
        Xapian::Query.new(Xapian::Query::OP_VALUE_RANGE, position, Xapit.serialize_value(value.begin), Xapit.serialize_value(value.end))
      elsif value.to_s.ends_with?("*") && value.to_s.strip.length > 2
        wildcard_query(value, "X#{name}-")
      else
        if value.kind_of? Time
          value = value.to_i
        elsif value.kind_of? Date
          value = value.to_time.to_i
        end
        "X#{name}-#{value.to_s.downcase}"
      end
    end
    
    # Expands the wildcard in the term (just at the end) and returns a query
    # which will match any term that starts with the given term.
    def wildcard_query(term, prefix = "")
      partial_term = term.sub(/\*$/, '') # remove asterisk at end if it exists
      parser = Xapian::QueryParser.new
      parser.database = Xapit::Config.database
      parser.parse_query(partial_term, Xapian::QueryParser::FLAG_PARTIAL, prefix)
    end
  end
end
