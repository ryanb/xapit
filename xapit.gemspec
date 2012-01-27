Gem::Specification.new do |s|
  s.name        = "xapit"
  s.version     = "0.3.0"
  s.author      = "Ryan Bates"
  s.email       = "ryan@railscasts.com"
  s.homepage    = "http://github.com/ryanb/xapit"
  s.summary     = "Ruby library for interacting with the Xapian full text search engine."
  s.description = "Ruby library for interacting with Xapian. Includes full text search, faceted options, spelling suggestions, and more."

  s.files        = Dir["{lib,spec,features,rails_generators,tasks}/**/*", "[A-Z]*", "init.rb", "install.rb", "uninstall.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'rack', '~> 1.3.4'

  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'cucumber', '~> 0.10.2'
  s.add_development_dependency 'rake'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
