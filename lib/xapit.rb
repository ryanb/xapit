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
  end
end

require 'xapit/client/membership'
require 'xapit/client/index_builder'
require 'xapit/client/collection'
require 'xapit/server/database'
require 'xapit/server/query'
require 'xapit/server/indexer'
