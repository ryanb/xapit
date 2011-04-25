require "fileutils"

module SpecMacros
  def load_xapit_database
    path = File.expand_path('../../../tmp/testdb', __FILE__)
    template = File.expand_path('../../fixtures/blankdb', __FILE__)
    FileUtils.rm_rf(path)
    Xapit.database = Xapit::Server::Database.new(path, template)
  end
end
