require "openxml/has_properties"

module OpenXml
  module ContainsProperties

    def self.included(base)
      base.class_eval do
        include HasProperties
        include InstanceMethods
      end
    end

    module InstanceMethods

      def property_xml(xml)
        props = properties.keys.map(&method(:send)).compact
        return if props.none?(&:render?) && properties_attributes.none?

        props.each { |prop| prop.to_xml(xml) }
      end

    end

  end
end
