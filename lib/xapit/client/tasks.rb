require "rack"

namespace :xapit do
  desc "Index all models for Xapit search"
  task :index => :environment do
    models = ActiveRecord::Base.send(:subclasses)
    Dir[Rails.root.join("app", "models", "**", "*.rb")].each do |file|
      models << File.basename(file, ".*").classify
    end
    models.uniq!
    models.select! { |m| m.respond_to? :xapit_model_adapter }
    Xapit.index(*models)
  end
end
