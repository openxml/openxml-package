module OpenXml
  module Properties
    class ValueProperty < BaseProperty
      attr_reader :value

      def initialize(value)
        @value = value
        raise ArgumentError, invalid_message unless valid?
      end

      def valid?
        ok_values.member? value
      end

      def invalid_message
        "#{value.inspect} is an invalid value for #{name}; acceptable: #{ok_values.join(", ")}"
      end

      def render?
        !value.nil?
      end

      def to_xml(xml)
        apply_namespace(xml).public_send(tag, :"#{value_attribute}" => value) do
          yield xml if block_given?
        end
      end

    private

      def value_attribute
        namespace.nil? ? "val" : "#{namespace}:val"
      end

    end
  end
end
