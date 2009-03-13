namespace :xapit
  desc "Index all xapit models."
  task :index => :environment do
    Xapit::IndexBlueprint.index_all
  end
end
