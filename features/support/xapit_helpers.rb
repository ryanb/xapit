module XapitHelpers
  def create_records(records,  perform_index = true)
    XapitMember.delete_all
    XapitMember.xapit do
      records.first.keys.each do |attribute|
        if block_given?
          yield(self, attribute)
        else
          text attribute
          field attribute
          facet attribute
          sortable attribute
        end
      end
    end
    records.each do |attributes|
      attributes.each do |key, value|
        attributes[key] = value.split(', ') if value.include? ', '
      end
      member = XapitMember.new(attributes)
      member.class.xapit_index_builder.add_document(member) if perform_index
    end
  end
end

World(XapitHelpers)
