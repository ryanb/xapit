namespace :xapit do
  desc "Index all xapit models."
  task :index => :environment do
    Xapit::Config.remove_database
    Xapit::IndexBlueprint.index_all do |member_class|
      puts "Indexing #{member_class.name}"
    end
  end
end
