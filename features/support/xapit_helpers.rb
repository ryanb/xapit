module XapitHelpers
  def create_records(records,  perform_index = true)
    XapitMember.delete_all
    XapitMember.xapit do
      records.first.keys.each do |attribute|
        if block_given?
          yield(attribute)
        else
          text attribute
          field attribute
          # index.facet attribute
          sortable attribute
        end
      end
    end
    records.each do |attributes|
      attributes.each do |key, value|
        attributes[key] = value.split(', ') if value.include? ', '
      end
      member = XapitMember.new(attributes)
      member.xapit_index if perform_index
    end
  end
end

World(XapitHelpers)
