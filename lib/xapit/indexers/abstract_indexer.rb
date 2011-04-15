module Xapit
  class AbstractIndexer
    def initialize(blueprint)
      @blueprint = blueprint
    end

    def add_member(member)
      database.add_document(document_for(member))
    end

    def update_member(member)
      database.replace_document("Q#{member.class}-#{member.id}", document_for(member))
    end

    def document_for(member)
      document = Xapit::Document.new
      document.data = "#{member.class}-#{member.id}"
      index_text_attributes(member, document)
      index_terms(other_terms(member), document)
      values(member).each do |identifier, value|
        document.values << value
        document.value_indexes << Xapit.value_index(identifier)
      end
      save_facet_options_for(member)
      document
    end

    def index_terms(terms, document)
      terms.each do |term|
        document.terms << term
        document.spellings << term if Config.spelling?
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
      facet_values(member).merge(sortable_values(member)).merge(field_values(member))
    end

    def sortable_values(member)
      @blueprint.sortable_attributes.inject({}) do |hash, sortable|
        value = member.send(sortable)
        value = value.first if value.kind_of? Array
        hash["sortable#{sortable}"] = Xapit.serialize_value(value)
        hash
      end
    end

    # TODO remove duplication with sortable_values
    def field_values(member)
      @blueprint.field_attributes.inject({}) do |hash, field|
        value = member.send(field)
        value = value.first if value.kind_of? Array
        hash["field#{field}"] = Xapit.serialize_value(value)
        hash
      end
    end

    def facet_values(member)
      @blueprint.facets.inject({}) do |hash, facet|
        hash["facet#{facet.attribute}"] = facet.identifiers_for(member).join("-")
        hash
      end
    end

    def save_facet_options_for(member)
      @blueprint.facets.each do |facet|
        facet.save_facet_options_for(member)
      end
    end

    private

    def database
      Config.database
    end
  end
end
