module Xapit
  # Singleton class for storing Xapit configuration settings. Currently this only includes the database path.
  class Config
    class << self
      attr_reader :options
      
      # Setup configuration options. The following options are supported.
      # 
      # <tt>:database_path</tt>:  Where the database is stored.
      # <tt>:stemming</tt>:       The language to use for stemming, defaults to "english".
      # <tt>:spelling</tt>:       True or false to enable/disable spelling, defaults to true.
      # <tt>:indexer</tt>:        Class to handle the indexing, defaults to SimpleIndexer.
      # <tt>:query_parser</tt>:   Class to handle the parsing, defaults to SimpleQueryParser.
      #
      def setup(options = {})
        if @options && options[:database_path] != @options[:database_path]
          @database = nil
          @writable_database = nil
        end
        @options = options.reverse_merge(default_options)
      end
      
      def default_options
        {
          :indexer => SimpleIndexer,
          :query_parser => SimpleQueryParser,
          :spelling => true,
          :stemming => "english"
        }
      end
      
      # See if setup options are already set.
      def setup?
        @options
      end
      
      # The configured path to the database.
      def path
        @options[:database_path]
      end
      
      def query_parser
        @options[:query_parser]
      end
      
      def indexer
        @options[:indexer]
      end
      
      def spelling?
        @options[:spelling]
      end
      
      def stemming
        @options[:stemming]
      end
      
      # Fetch Xapian::Database object at configured path. Database is stored in memory.
      def database
        @writable_database || (@database ||= Xapian::Database.new(path))
      end
      
      # Fetch Xapian::WritableDatabase object at configured path. Database is stored in memory.
      # Creates the database directory if needed.
      def writable_database
        FileUtils.mkdir_p(File.dirname(path)) unless File.exist?(File.dirname(path))
        @writable_database ||= Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OPEN)
      end
      
      # Removes the configured database file and clears the stored one in memory.
      def remove_database # this can be a bit dangers, maybe do some checking here first?
        FileUtils.rm_rf(path) if File.exist? path
        @database = nil
        @writable_database = nil
      end
    end
  end
end
