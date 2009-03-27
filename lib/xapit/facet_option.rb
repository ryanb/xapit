module Xapit
  class FacetOption
    attr_accessor :facet, :name
    
    def self.find(id)
      enquire = Xapian::Enquire.new(Xapit::Config.database)
      enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, ["Q#{name}-#{id}"])
      match = enquire.mset(0, 1).matches.first
      if match.nil?
        raise "Unable to find facet option for #{id}."
      else
        make(*match.document.data.split('|||'))
      end
    end
    
    # change this to "new" later on
    def self.make(class_name, facet_attribute, name)
      option = new(nil, nil, nil)
      option.facet = class_name.constantize.xapit_facet_blueprint(facet_attribute)
      option.name = name
      option
    end
    
    def initialize(blueprint, match, existing_facet_identifiers)
      @blueprint = blueprint
      @match = match
      @existing_facet_identifiers = existing_facet_identifiers
    end
    
    def name
      @name || begin
        class_name, id = @match.document.data.split('-')
        record.send(@blueprint.attribute).to_s
      end
    end
    
    def count
      # add one because Xapian counts the collapsed record as one
      @match.collapse_count + 1
    end
    
    def identifier
      if @name
        Digest::SHA1.hexdigest(facet.attribute.to_s + name)[0..6]
      else
        @blueprint.identifiers_for(record).first
      end
    end
    
    def save
      doc = Xapian::Document.new
      doc.data = [facet.member_class.name, facet.attribute, name].join("|||")
      doc.add_term("Q#{self.class.name}-#{identifier}")
      Xapit::Config.writable_database.add_document(doc)
    end
    
    def to_param
      (@existing_facet_identifiers + [identifier]).join('-')
    end
    
    private
    
    def record
      # TODO cache record fetching?
      class_name, id = @match.document.data.split('-')
      class_name.constantize.find(id)
    end
  end
end
