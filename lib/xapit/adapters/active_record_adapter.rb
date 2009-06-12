module Xapit
  class ActiveRecordAdapter
    def initialize(target)
      @target = target
    end
    
    def find_single(id)
      @target.find(id)
    end
    
    def find_multiple(ids)
      @target.find(ids)
    end
    
    def find_each(*args, &block)
      @target.find_each(*args, &block)
    end
  end
end
