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


  class LocalDatabase
    def initialize(path, template_path)
      @path = path
      @template_path = template_path
    end

    def xapian_database
      @xapian_database ||= generate_database
    end

    def add_document(document)
      xapian_database.add_document(document.xapian_document)
      document.spellings.each do |spelling|
        xapian_database.add_spelling(spelling)
      end
    end

    def delete_document(id)
      xapian_database.delete_document(id)
    end

    def replace_document(id, document)
      xapian_database.replace_document(id, document.xapian_document)
    end

    def get_spelling_suggestion(term)
      xapian_database.get_spelling_suggestion(term)
    end

    def add_spelling(term)
      xapian_database.add_spelling(term)
    end

    def doccount
      xapian_database.doccount
    end

    private

    def generate_database
      FileUtils.mkdir_p(File.dirname(@path)) unless File.exist?(File.dirname(@path))
      if @template_path && !File.exist?(@path)
        FileUtils.cp_r(@template_path, @path)
      end
      Xapian::WritableDatabase.new(@path, Xapian::DB_CREATE_OR_OPEN)
    end
  end
end
