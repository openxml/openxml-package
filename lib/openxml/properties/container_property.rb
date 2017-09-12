require "openxml/has_attributes"

module OpenXml
  module Properties
    class ContainerProperty < BaseProperty
      include Enumerable
      include HasAttributes

      class << self

        def child_class(*args)
          unless args.empty?
            @child_classes = args.map { |arg|
              prop_name = arg.to_s.split(/_/).map(&:capitalize).join # LazyCamelCase
              const_name = (self.to_s.split(/::/)[0...-1] + [prop_name]).join("::")
              Object.const_get const_name
            }
          end

          @child_classes
        end
        alias child_classes child_class

      end

      def initialize
        @children = []
      end

      def <<(child)
        raise ArgumentError, invalid_child_message unless valid_child?(child)
        children << child
      end

      def each(*args, &block)
        children.each(*args, &block)
      end

      def render?
        !children.length.zero?
      end

      def to_xml(xml)
        return unless render?

        apply_namespace(xml).public_send(tag, xml_attributes) {
          each { |child| child.to_xml(xml) }
        }
      end

    private

      attr_reader :children

      def invalid_child_message
        class_name = self.class.to_s.split(/::/).last
        "#{class_name} must be instances of one of the following: #{child_classes}"
      end

      def valid_child?(child)
        child_classes.any? { |child_class| child.is_a?(child_class) }
      end

      def child_classes
        self.class.child_classes
      end

    end
  end
end
