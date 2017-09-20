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
        props = active_properties
        return unless render_properties? props
        props.each { |prop| prop.to_xml(xml) }
      end

      def properties_attributes
        {}
      end

    end

  end
end
