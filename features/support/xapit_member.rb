class XapitMember
  include Xapit::Membership
  
  attr_reader :id
  
  def self.find_each(&block)
    @@records.each(&block) if @@records
  end
  
  def self.delete_all
    @@records = []
  end
  
  def self.find(id)
    @@records.detect { |r| r.id == id.to_i }
  end
  
  def initialize(attributes = {})
    @@records ||= []
    @id = @@records.size + 1
    @attributes = attributes
    @@records << self
  end
  
  def method_missing(name, *args)
    if @attributes.has_key? name
      @attributes[name]
    else
      super
    end
  end
end
