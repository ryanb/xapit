module Xapit
  module Client
    class Railtie < Rails::Railtie
      initializer "xapit.config" do
        path = Rails.root.join("config/xapit.yml")
        Xapit.load_config(path, Rails.env) if path.exist?
      end

      initializer "xapit.membership" do
        ActiveRecord::Base.send(:include, Xapit::Client::Membership) if defined? ActiveRecord
      end

      rake_tasks do
        load File.expand_path("../tasks.rb", __FILE__)
      end
    end
  end
end
