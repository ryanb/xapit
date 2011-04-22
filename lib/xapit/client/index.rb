module Xapit
  module Client
    class Index
      def initialize(builder, member)
        @builder = builder
        @member = member
      end

      def data
        {
          :class => @member.class.name,
          :id => @member.id,
          :texts => text_data,
        }
      end

      def text_data
        texts = {}
        @builder.text_attributes.each do |name, options|
          texts[name] = {:value => @member.send(name)}.merge(options)
        end
        texts
      end
    end
  end
end
