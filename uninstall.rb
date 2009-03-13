path = "#{Rails.root}/config/initializers/setup_xapit.rb"
if File.exist? path
  puts "Removing setup_xapit.rb initializer."
  File.delete(path)
end
