module Xapit
  class SimpleQueryParser
    attr_writer :base_query
    attr_reader :parsed
    
    def initialize(member_class, search_text, options = {})
      @member_class = member_class
      @search_text = search_text.to_s
      @options = options
      @parsed = parse(search_text.to_s.downcase)
    end
    
    def query
      if (@search_text.split + condition_terms + facet_terms).empty?
        base_query
      else
        @query ||= base_query.and_query(xapian_query(@parsed)).and_query(condition_terms + facet_terms)
      end
    end
    
    def current_page
      @options[:page] ? @options[:page].to_i : 1
    end
    
    def per_page
      @options[:per_page] ? @options[:per_page].to_i : 20
    end
    
    def sort_by_values
      if @options[:order] && @member_class
        index = @member_class.xapit_index_blueprint
        if @options[:order].kind_of? Array
          @options[:order].map do |attribute|
            index.sortable_position_for(attribute)
          end
        else
          [index.sortable_position_for(@options[:order])]
        end
      end
    end
    
    def base_query
      @base_query ||= Query.new(initial_query_string)
    end
    
    def initial_query_string
      @member_class ? "C" + @member_class.name : ""
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
    
    # REFACTORME this is a bit complex for one method...
    def xapian_query(instructions = nil)
      instructions ||= @parsed
      instructions = [:add, instructions] if instructions.kind_of? String
      operator = (instructions.first == :or ? Xapian::Query::OP_OR : Xapian::Query::OP_AND)
      words = instructions[1..-1].select { |i| i.kind_of? String }
      query = Xapian::Query.new(operator, words) unless words.empty?
      instructions[1..-1].select { |i| i.kind_of? Array }.each do |sub_instructions|
        if sub_instructions.first == :not
          sub_operator = Xapian::Query::OP_AND_NOT
        else
          sub_operator = operator
        end
        if query
          query = Xapian::Query.new(sub_operator, query, xapian_query(sub_instructions))
        else
          query = xapian_query(sub_instructions)
        end
      end
      query
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
          words = text.scan(/(?:\bnot\s+)?[^\s]+/i)
          words.map! do |word|
            if word =~ /^not\s/i
              [:not, word.sub(/^not\s+/i, '')]
            else
              word
            end
          end
          [:and, *words]
        else
          text
        end
      end
    end
  end
end
