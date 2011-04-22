module Xapit
  module Client
    class Index
      def initialize(builder, member)
        @builder = builder
        @member = member
      end

      def data
        {:text => @member.send(@builder.text_attributes.first).split}
      end
    end
  end
end
