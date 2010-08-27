module Xapit
  class LocalDatabase
    def initialize(path, template_path)
      @path = path
      @template_path = template_path
    end
    
    def readable_database
      writable_database
    end
    
    def writable_database
      @writable_database ||= generate_database
    end
    
    def add_document(document)
      writable_database.add_document(document)
    end
    
    def delete_document(id)
      writable_database.delete_document(id)
    end
    
    def replace_document(id, document)
      writable_database.replace_document(id, document)
    end
    
    def get_spelling_suggestion(term)
      readable_database.get_spelling_suggestion(term)
    end
    
    def add_spelling(term)
      writable_database.add_spelling(term)
    end
    
    def doccount
      readable_database.doccount
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
