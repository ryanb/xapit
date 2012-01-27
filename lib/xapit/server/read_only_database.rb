module Xapit
  module Server
    class ReadOnlyDatabase < Database
      def add_document(data)
        save_changes("add_document", data)
      end

      def remove_document(data)
        save_changes("remove_document", data)
      end

      def update_document(data)
        save_changes("update_document", data)
      end

    private

      def save_changes(action, data)
        File.open(Xapit.changes_path, "a") do |file|
          file.puts({action: action, data: data}.to_json)
        end
      end

      def load_database
        Xapian::Database.new(@path)
      end
    end
  end
end
