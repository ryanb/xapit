module XapitHelpers
  def create_records(records,  perform_index = true)
    Xapit::Config.remove_database
    XapitMember.delete_all
    XapitMember.xapit do |index|
      records.first.keys.each do |attribute|
        index.text attribute
        index.field attribute
        index.facet attribute
        index.sortable attribute
      end
    end
    records.each do |attributes|
      attributes.each do |key, value|
        attributes[key] = value.split(', ') if value.include? ', '
      end
      XapitMember.new(attributes.symbolize_keys)
    end
    Xapit.index_all if perform_index
  end
end

World { |world| world.extend XapitHelpers }
