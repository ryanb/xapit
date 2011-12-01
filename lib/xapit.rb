require 'xapian'
require 'digest/sha1'
require 'rack'
require 'json'
require 'net/http'
require 'time'

module Xapit
  # A general Xapit exception
  class Error < StandardError; end

  # Raised when accessing the database when Xapit is disabled
  class Disabled < Error; end

  class << self
    attr_reader :config

    def reset_config
      @database = nil
      @config = {
        :enabled => true,
        :spelling => true,
        :stemming => "english"
      }
    end

    def reload
      reset_config
      @config.merge!(@loaded_config) if @loaded_config
    end

    def database
      raise Disabled, "Unable to access Xapit database because it is disabled in configuration." unless Xapit.config[:enabled]
      if config[:server]
        @database ||= Xapit::Client::RemoteDatabase.new(config[:server])
      else
        @database ||= Xapit::Server::Database.new(config[:database_path])
      end
    end

    def load_config(filename, environment)
      @loaded_config = symbolize_keys(YAML.load_file(filename)[environment.to_s])
      raise ArgumentError, "The #{environment} environment does not exist in #{filename}" if @loaded_config.nil?
      @config.merge!(@loaded_config)
    end

    def value_index(type, attribute)
      Zlib.crc32(["xapit", type, attribute].join) % 99999999 # TODO: Figure out the true max of a xapian value index
    end

    def facet_identifier(attribute, value)
      Digest::SHA1.hexdigest(["xapit", attribute, value].join)[0..6]
    end

    def search(*args)
      Xapit::Client::Collection.new.not_in_classes("FacetOption").search(*args)
    end

    def serialize_value(value)
      if value.kind_of?(Time)
        Xapian.sortable_serialise(value.to_i)
      elsif value.to_s =~ /^\d{4}-\d{2}-\d{2}/
        Xapian.sortable_serialise(Time.parse(value.to_s).to_i)
      elsif value.kind_of?(Numeric) || value.to_s =~ /^\d+$/
        Xapian.sortable_serialise(value.to_f)
      else
        value.to_s.downcase
      end
    rescue ArgumentError # in case Time.parse errors out
      value.to_s.downcase
    end

    def enable
      config[:enabled] = true
    end

    def index(*models)
      models.each do |model|
        model.xapit_model_adapter.index_all
      end
    end

    def query_class
      if config[:query_class]
        Kernel.const_get(config[:query_class])
      else
        Xapit::Server::Query
      end
    end

    # from http://snippets.dzone.com/posts/show/11121
    # could use some refactoring
    def symbolize_keys(arg)
      case arg
      when Array
        arg.map { |elem| symbolize_keys(elem) }
      when Hash
        Hash[
          arg.map { |key, value|
            k = key.is_a?(String) ? key.to_sym : key
            v = symbolize_keys(value)
            [k,v]
          }]
      else
        arg
      end
    end
  end

  reset_config
end

require 'xapit/server/database'
require 'xapit/server/query'
require 'xapit/server/indexer'
require 'xapit/server/app'
require 'xapit/client/membership'
require 'xapit/client/index_builder'
require 'xapit/client/collection'
require 'xapit/client/facet'
require 'xapit/client/facet_option'
require 'xapit/client/remote_database'
require 'xapit/client/railtie' if defined? Rails
require 'xapit/client/model_adapters/abstract_model_adapter'
require 'xapit/client/model_adapters/default_model_adapter'
require 'xapit/client/model_adapters/active_record_adapter'
