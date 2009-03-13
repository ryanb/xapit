File.open("#{Rails.root}/config/initializers/setup_xapit.rb", "w") do |f|
  f.write <<-STR
Xapit::Config.setup(:database_path => "\#{Rails.root}/db/xapiandb")
STR
end
