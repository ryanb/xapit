class XapitGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "config/initializers"
      m.file "setup_xapit.rb", "config/initializers/setup_xapit.rb"

      m.directory "lib/tasks"
      m.file "xapit.rake", "lib/tasks/xapit.rake"
    end
  end

  protected
    def banner
      <<-EOS
Generates files necessary to setup Xapit.

USAGE: #{$0} #{spec.name}
EOS
    end
end
