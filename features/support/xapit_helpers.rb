module XapitHelpers
  def create_records(records,  perform_index = true)
    Xapit.remove_database
    XapitMember.delete_all
    XapitMember.xapit do |index|
      records.first.keys.each do |attribute|
        if block_given?
          yield(index, attribute)
        else
          index.text attribute
          index.field attribute
          index.facet attribute
          index.sortable attribute
        end
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

World(XapitHelpers)
