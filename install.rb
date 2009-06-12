source = File.join(File.dirname(__FILE__), '/rails_generators/xapit/templates/setup_xapit.rb')
destination = "#{Rails.root}/config/initializers/setup_xapit.rb"
unless File.exist? destination
  puts "Adding setup_xapit.rb initializer."
  File.cp(source, destination)
end
