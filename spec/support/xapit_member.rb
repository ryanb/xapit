class XapitMember
  include Xapit::Client::Membership

  attr_reader :id

  def self.find_each(&block)
    @@records.each(&block) if @@records
  end

  def self.delete_all
    @@records = []
  end

  def self.find(ids)
    if ids.kind_of? Array
      # change the order to mimic database where we can't predict the order
      ids.sort.map { |id| @@records.detect { |r| r.id == id.to_i } }
    else
      @@records.detect { |r| r.id == ids.to_i }
    end
  end

  def self.find_by_id(id)
    find(id)
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

  def update_attribute(name, value)
    @attributes[name] = value
  end
end
