module Xapit
  # This adapter is used for all ActiveRecord models. See AbstractAdapter for details.
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(member_class)
      member_class.ancestors.map(&:to_s).include? "ActiveRecord::Base"
    end

    def find_single(id, *args)
      @target.find_by_id(id, *args)
    end

    def find_multiple(ids)
      @target.find(ids)
    end

    def find_each(*args, &block)
      @target.find_each(*args, &block)
    end
  end
end
