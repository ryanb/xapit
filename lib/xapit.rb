require 'digest/sha1'
require 'rubygems'
require 'xapian'

# Looking for more documentation? A good place to start is Xapit::Membership
module Xapit
  # Index all membership classes with xapit defined. Delegates to Xapit::IndexBlueprint.
  # You will likely want to call Xapit.remove_database before this.
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

  # Setup configuration options. The following options are supported.
  #
  # <tt>:database_path</tt>:     Where the database is stored.
  # <tt>:stemming</tt>:          The language to use for stemming, defaults to "english".
  # <tt>:spelling</tt>:          True or false to enable/disable spelling, defaults to true.
  # <tt>:indexer</tt>:           Class to handle the indexing, defaults to SimpleIndexer.
  # <tt>:query_parser</tt>:      Class to handle the parsing, defaults to ClassicQueryParser.
  # <tt>:breadcrumb_facets</tt>: Use breadcrumb mode for applied facets. See Collection#applied_facet_options for details.
  #
  def self.setup(*args)
    Config.setup(*args)
  end

  # Removes the configured database file and clears the stored one in memory.
  def self.remove_database
    Config.remove_database
  end

  def self.serialize_value(value)
    if value.kind_of?(Date)
      Xapian.sortable_serialise(value.to_time.to_i)
    elsif value.kind_of?(Time)
      Xapian.sortable_serialise(value.to_i)
    elsif value.kind_of?(Numeric) || value.to_s =~ /^[0-9]+$/
      Xapian.sortable_serialise(value.to_f)
    else
      value.to_s.downcase
    end
  end

  # The Xapian value index position of an attribute
  def self.value_index(*args)
    Zlib.crc32(["xapit", *args].join) % 99999999 # Figure out the true max of a xapian value index
  end
end

require 'xapit/client/membership'
require 'xapit/client/index_builder'
require 'xapit/client/index'
require 'xapit/client/collection'
require 'xapit/client/facet'
require 'xapit/client/adapters/abstract_adapter'
require 'xapit/client/adapters/active_record_adapter'
require 'xapit/client/adapters/data_mapper_adapter'
require 'xapit/server/index_blueprint'
require 'xapit/server/config'
require 'xapit/server/server'
require 'xapit/server/facet_blueprint'
require 'xapit/server/facet_option'
require 'xapit/server/local_database'
require 'xapit/server/document'
require 'xapit/server/query'
require 'xapit/server/query_parsers/abstract_query_parser'
require 'xapit/server/query_parsers/simple_query_parser'
require 'xapit/server/query_parsers/classic_query_parser'
require 'xapit/server/indexers/abstract_indexer'
require 'xapit/server/indexers/simple_indexer'
require 'xapit/server/indexers/classic_indexer'
require 'xapit/server/indexer'
