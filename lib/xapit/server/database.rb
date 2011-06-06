module Xapit
  module Server
    class Database
      def initialize(path, template_path)
        @path = path
        @template_path = template_path
      end

      def xapian_database
        @xapian_database ||= load_database
      end

      def add_document(data)
        xapian_database.add_document(Indexer.new(data).document)
      end

      def query(data)
        Query.new(data).data
      end

      def spelling_suggestion(data)
        Query.new(data).spelling_suggestion
      end

      private

      def load_database
        FileUtils.mkdir_p(File.dirname(@path)) unless File.exist?(File.dirname(@path))
        if @template_path && !File.exist?(@path)
          FileUtils.cp_r(@template_path, @path)
        end
        Xapian::WritableDatabase.new(@path, Xapian::DB_CREATE_OR_OPEN)
      end
    end
  end
end
