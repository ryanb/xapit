module Xapit
  # This adapter is used for all DataMapper models. See AbstractAdapter for details.
  class DataMapperAdapter < AbstractAdapter
    def self.for_class?(member_class)
      member_class.ancestors.map(&:to_s).include? "DataMapper::Resource"
    end

    # TODO override the rest of the methods here...
  end
end
