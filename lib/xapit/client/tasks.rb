require "rack"
require "fileutils"

namespace :xapit do
  desc "Index all models for Xapit search"
  task :index => :environment do
    raise "No Xapian database specified in config." if Xapit.config[:database_path].blank?
    FileUtils.rm_rf("tmp/xapit") if File.exist? "tmp/xapit"
    FileUtils.mv(Xapit.config[:database_path], "tmp/xapit") if File.exist? Xapit.config[:database_path]
    models = ActiveRecord::Base.subclasses
    Dir[Rails.root.join("app", "models", "**", "*.rb")].each do |file|
      # I hate to rescue nil, maybe there's a better way to handle unknown constants
      models << File.basename(file, ".*").classify.constantize rescue nil
    end
    xapit_models = models.compact.uniq.select { |m| m.respond_to? :xapit_model_adapter }
    Xapit.index(*xapit_models)
  end
end
