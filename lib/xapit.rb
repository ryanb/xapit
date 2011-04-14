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
end

require 'xapit/membership'
require 'xapit/index_blueprint'
require 'xapit/collection'
require 'xapit/config'
require 'xapit/facet_blueprint'
require 'xapit/facet'
require 'xapit/facet_option'
require 'xapit/local_database'
require 'xapit/document'
require 'xapit/query'
require 'xapit/query_parsers/abstract_query_parser'
require 'xapit/query_parsers/simple_query_parser'
require 'xapit/query_parsers/classic_query_parser'
require 'xapit/indexers/abstract_indexer'
require 'xapit/indexers/simple_indexer'
require 'xapit/indexers/classic_indexer'
require 'xapit/adapters/abstract_adapter'
require 'xapit/adapters/active_record_adapter'
require 'xapit/adapters/data_mapper_adapter'
