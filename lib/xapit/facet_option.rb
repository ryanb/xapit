module Xapit
  # A facet option is a specific value or choice for a facet. See Xapit::Facet for details on how to use it.
  class FacetOption
    attr_accessor :facet, :name, :existing_facet_identifiers, :count
    
    # Fetch a facet option given an id.
    def self.find(id)
      match = Query.new("Q#{name}-#{id}").matches(:offset => 0, :limit => 1).first
      if match.nil?
        raise "Unable to find facet option for #{id}."
      else
        class_name, facet_attribute, name = match.document.data.split('|||')
        new(class_name.to_s, facet_attribute.to_s, name.to_s)
      end
    end
    
    # See if the given facet option exists with this id.
    def self.exist?(id)
      Query.new("Q#{name}-#{id}").count >= 1
    end
    
    def initialize(class_name, facet_attribute, name)
      @facet = class_name.constantize.xapit_facet_blueprint(facet_attribute) if class_name && facet_attribute
      @name = name
    end
    
    def identifier
      Digest::SHA1.hexdigest(facet.attribute.to_s + name)[0..6]
    end
    
    # Saves the given facet option to the database if it hasn't been already.
    def save
      unless self.class.exist?(identifier)
        doc = Xapian::Document.new
        doc.data = [facet.member_class.name, facet.attribute, name].join("|||")
        doc.add_term("Q#{self.class.name}-#{identifier}")
        Xapit::Config.writable_database.add_document(doc)
      end
    end
    
    # Converts the facet to be used in a URL. It adds to the existing ones for convenience.
    # If this facet option is currently selected, then this will return all selected facets except
    # this one. This conveniently allows you to use this as both an "add this facet" and "remove this facet" link.
    def to_param
      if existing_facet_identifiers.include? identifier
        (existing_facet_identifiers - [identifier]).join('-')
      else
        (existing_facet_identifiers + [identifier]).join('-')
      end
    end
  end
end
