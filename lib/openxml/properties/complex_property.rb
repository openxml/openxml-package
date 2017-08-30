require "openxml/has_attributes"

module OpenXml
  module Properties
    class ComplexProperty < BaseProperty
      include HasAttributes

      def to_xml(xml)
        return unless render?
        apply_namespace(xml).public_send(tag, xml_attributes) do
          yield xml if block_given?
        end
      end

      def render?
        !xml_attributes.empty?
      end

    end
  end
end
