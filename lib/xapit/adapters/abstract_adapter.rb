module Xapit
  # Adapters are used to support multiple ORMs (ActiveRecord, Datamapper, Sequel, etc.).
  # It abstracts out all find calls so they can be handled differently for each ORM.
  # To create your own adapter, subclass AbstractAdapter and override the placeholder methods.
  # See ActiveRecordAdapter for an example.
  class AbstractAdapter
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end
    
    # Returns all adapter classes.
    def self.subclasses
      @subclasses
    end
    
    # Sets the @target instance, this is the class the adapter needs to forward
    # its messages to.
    def initialize(target)
      @target = target
    end
    
    # Used to determine if the given adapter should be used for the passed in class.
    # Usually one will see if it inherits from another class (ActiveRecord::Base)
    def self.for_class?(member_class)
      raise "To be implemented in subclass"
    end
    
    # Fetch a single record by the given id.
    def find_single(id)
      raise "To be implemented in subclass"
    end
    
    # Fetch multiple records from the passed in array of ids.
    def find_multiple(ids)
      raise "To be implemented in subclass"
    end
    
    # Iiterate through all records using the given parameters.
    # It should yield to the block and pass in each record individually.
    # The args are the same as those passed from the XapitMember#xapit call.
    def find_each(*args, &block)
      raise "To be implemented in subclass"
    end
  end
end
