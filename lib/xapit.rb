require 'digest/sha1'
require 'rubygems'
require 'xapian'

# Looking for more documentation? A good place to start is Xapit::Membership
module Xapit
  
  # Index all membership classes with xapit defined. Delegates to Xapit::IndexBlueprint.
  def self.index_all(*args, &block)
    IndexBlueprint.index_all(*args, &block)
  end
  
  # Used to perform a search on all indexed models. The returned collection can
  # contain instances of different classes which were indexed.
  # 
  #   # perform a simple full text search
  #   @records = Xapit.search("phone")
  # 
  # See Xapit::Membership for details on search options.
  def self.search(*args)
    Collection.new(nil, *args)
  end
end

require File.dirname(__FILE__) + '/xapit/membership'
require File.dirname(__FILE__) + '/xapit/index_blueprint'
require File.dirname(__FILE__) + '/xapit/collection'
require File.dirname(__FILE__) + '/xapit/config'
require File.dirname(__FILE__) + '/xapit/facet_blueprint'
require File.dirname(__FILE__) + '/xapit/facet'
require File.dirname(__FILE__) + '/xapit/facet_option'
require File.dirname(__FILE__) + '/xapit/query'
require File.dirname(__FILE__) + '/xapit/query_parsers/abstract_query_parser'
require File.dirname(__FILE__) + '/xapit/query_parsers/simple_query_parser'
require File.dirname(__FILE__) + '/xapit/query_parsers/classic_query_parser'
require File.dirname(__FILE__) + '/xapit/indexers/abstract_indexer'
require File.dirname(__FILE__) + '/xapit/indexers/simple_indexer'
require File.dirname(__FILE__) + '/xapit/indexers/classic_indexer'
