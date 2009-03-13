module Xapit
  class FacetOption
    attr_accessor :name
    
    def identifier
      @identifier ||= generate_identifier
    end
    
    private
    
    def generate_identifier
      Digest::SHA1.hexdigest(name)[0..6]
    end
  end
end
