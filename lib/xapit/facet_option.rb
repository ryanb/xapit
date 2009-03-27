module Xapit
  class FacetOption
    attr_accessor :facet, :name, :existing_facet_identifiers, :count
    
    def self.find(id)
      enquire = Xapian::Enquire.new(Config.database)
      enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, ["Q#{name}-#{id}"])
      match = enquire.mset(0, 1).matches.first
      if match.nil?
        raise "Unable to find facet option for #{id}."
      else
        new(*match.document.data.split('|||'))
      end
    end
    
    def self.exist?(id)
      enquire = Xapian::Enquire.new(Config.database)
      enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, ["Q#{name}-#{id}"])
      enquire.mset(0, 1).matches_estimated >= 1
    end
    
    def initialize(class_name, facet_attribute, name)
      @facet = class_name.constantize.xapit_facet_blueprint(facet_attribute) if class_name && facet_attribute
      @name = name
    end
    
    def identifier
      Digest::SHA1.hexdigest(facet.attribute.to_s + name)[0..6]
    end
    
    def save
      unless self.class.exist?(identifier)
        doc = Xapian::Document.new
        doc.data = [facet.member_class.name, facet.attribute, name].join("|||")
        doc.add_term("Q#{self.class.name}-#{identifier}")
        Xapit::Config.writable_database.add_document(doc)
      end
    end
    
    def to_param
      if existing_facet_identifiers.include? identifier
        (existing_facet_identifiers - [identifier]).join('-')
      else
        (existing_facet_identifiers + [identifier]).join('-')
      end
    end
  end
end
