module SpecMacros
  def load_xapit_database
    Xapit.reset_config
    Xapit.config[:spelling] = false
  end
end
