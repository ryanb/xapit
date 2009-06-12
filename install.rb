path = "#{Rails.root}/config/initializers/setup_xapit.rb"
unless File.exist? path
  puts "Adding setup_xapit.rb initializer."
  File.open(path, "w") do |f|
    f.write <<-EOS
Xapit.setup(:database_path => "\#{Rails.root}/db/xapiandb")
EOS
  end
end
