module Xapit
  module Server
    class Database
      COMMANDS = %w[query add_document remove_document update_document spelling_suggestion reopen]

      def initialize(path)
        @path = path
      end

      def xapian_database
        @xapian_database ||= load_database
      end

      def add_document(data)
        xapian_database.add_document(Indexer.new(data).document)
      end

      def remove_document(data)
        xapian_database.delete_document(Indexer.new(data).id_term)
      end

      def update_document(data)
        indexer = Indexer.new(data)
        xapian_database.replace_document(indexer.id_term, indexer.document)
      end

      def query(data)
        Xapit.query_class.new(data).data
      end

      def spelling_suggestion(data)
        Xapit.query_class.new(data).spelling_suggestion
      end

      def reopen(data = nil)
        xapian_database.reopen
      end

    private

      def load_database
        if @path
          FileUtils.mkdir_p(File.dirname(@path)) unless File.exist?(File.dirname(@path))
          Xapian::WritableDatabase.new(@path, Xapian::DB_CREATE_OR_OPEN)
        else
          Xapian.inmemory_open
        end
      end
    end
  end
end
