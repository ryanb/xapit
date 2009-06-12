module Xapit
  class AbstractIndexer
    def initialize(blueprint)
      @blueprint = blueprint
    end
    
    def add_member(member)
      database.add_document(document_for(member))
    end
    
    def document_for(member)
      document = Xapian::Document.new
      document.data = "#{member.class}-#{member.id}"
      index_text_attributes(member, document)
      index_terms(other_terms(member), document)
      values(member).each_with_index do |value, index|
        document.add_value(index, value)
      end
      save_facet_options_for(member)
      document
    end
    
    def index_terms(terms, document)
      terms.each do |term|
        document.add_term(term)
        database.add_spelling(term) if Config.spelling?
      end
    end
    
    def index_text_attributes(member, document)
      # to be overridden by subclass
    end
    
    def other_terms(member)
      base_terms(member) + field_terms(member) + facet_terms(member)
    end
    
    def base_terms(member)
      ["C#{member.class}", "Q#{member.class}-#{member.id}"]
    end
    
    def field_terms(member)
      @blueprint.field_attributes.map do |name|
        [member.send(name)].flatten.map do |value|
          if value.kind_of? Time
            value = value.to_i
          elsif value.kind_of? Date
            value = value.to_time.to_i
          end
          "X#{name}-#{value.to_s.downcase}"
        end
      end.flatten
    end
    
    def facet_terms(member)
      @blueprint.facets.map do |facet|
        facet.identifiers_for(member).map { |id| "F#{id}" }
      end.flatten
    end
    
    # used primarily by search similar functionality
    def text_terms(member) # REFACTORME some duplicaiton with simple indexer
      @blueprint.text_attributes.map do |name, options|
        content = member.send(name).to_s
        if options[:proc]
          options[:proc].call(content).reject(&:blank?).map(&:to_s).map(&:downcase)
        else
          content.scan(/\w+/u).map(&:downcase)
        end
      end.flatten
    end
    
    def values(member)
      facet_values(member) + sortable_values(member)
    end
    
    def sortable_values(member)
      @blueprint.sortable_attributes.map do |sortable|
        values = member.send(sortable)
        [values].flatten.map do |value|
          if value.kind_of?(Numeric) || value.to_s =~ /^[0-9]+$/
            Xapian.sortable_serialise(value.to_f)
          else
            value.to_s.downcase
          end
        end
      end.flatten
    end
    
    def facet_values(member)
      @blueprint.facets.map do |facet|
        facet.identifiers_for(member).join("-")
      end
    end
    
    def save_facet_options_for(member)
      @blueprint.facets.each do |facet|
        facet.save_facet_options_for(member)
      end
    end
    
    private
    
    def database
      Config.writable_database
    end
  end
end
