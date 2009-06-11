# TODO investigate why this is needed to ensure it doesn't load twice
unless @xapit_rake_loaded
  @xapit_rake_loaded = true
  namespace :xapit do
    desc "Index all xapit models."
    task :index => :environment do
      Xapit::Config.remove_database
      Xapit.index_all do |member_class|
        puts "Indexing #{member_class.name}"
      end
    end
  end
end
