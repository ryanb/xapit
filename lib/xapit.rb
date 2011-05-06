require 'xapian'

module Xapit
  class << self
    attr_accessor :database

    def reset
      @database = nil
    end

    def value_index(*args)
      Zlib.crc32(["xapit", *args].join) % 99999999 # TODO: Figure out the true max of a xapian value index
    end

    def search(*args)
      Xapit::Client::Collection.new.search(*args)
    end
  
    def serialize_value(value)
      if value.kind_of?(Time)
        Xapian.sortable_serialise(value.to_i)
      elsif value.kind_of?(Numeric) || value.to_s =~ /^[0-9]+$/
        Xapian.sortable_serialise(value.to_f)
      else
        value.to_s.downcase
      end
    end
  end
end

require 'xapit/client/membership'
require 'xapit/client/index_builder'
require 'xapit/client/collection'
require 'xapit/server/database'
require 'xapit/server/query'
require 'xapit/server/indexer'
