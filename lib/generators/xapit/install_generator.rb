module Xapit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def copy_files
        copy_file "xapit.yml", "config/xapit.yml"
        copy_file "xapit.ru", "xapit.ru"
      end
    end
  end
end
