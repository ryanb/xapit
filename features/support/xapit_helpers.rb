module XapitHelpers
  def create_records(records,  perform_index = true)
    Xapit::Config.remove_database
    XapitMember.delete_all
    XapitMember.xapit do |index|
      records.first.keys.each do |attribute|
        index.text attribute
        index.field attribute
        index.facet attribute
      end
    end
    records.each do |attributes|
      XapitMember.new(attributes.symbolize_keys)
    end
    Xapit::IndexBlueprint.index_all if perform_index
  end
end

World { |world| world.extend XapitHelpers }
