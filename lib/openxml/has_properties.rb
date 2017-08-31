module OpenXml
  module HasProperties

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def properties_tag(*args)
        @properties_tag = args.first if args.any?
        @properties_tag
      end

      def value_property(name, as: nil)
        attr_reader name

        properties[name] = (as || name).to_s
        class_name = properties[name].split("_").map(&:capitalize).join

        class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(value)
          instance_variable_set "@#{name}", Properties::#{class_name}.new(value)
        end
        CODE
      end

      def property(name, as: nil)
        properties[name] = (as || name).to_s
        class_name = properties[name].split("_").map(&:capitalize).join

        class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}(*args)
          if instance_variable_get("@#{name}").nil?
            instance_variable_set "@#{name}", Properties::#{class_name}.new(*args)
          end

          instance_variable_get "@#{name}"
        end
        CODE
      end

      def properties
        @properties ||= {}
      end

      def properties_attribute(name, **args)
        properties_element.attribute name, **args
        define_method "#{name}=" do |value|
          properties_element.public_send :"#{name}=", value
        end

        define_method name.to_s do
          properties_element.public_send name.to_sym
        end
      end

      def properties_element
        this = self
        @properties_element ||= Class.new(OpenXml::Element) do
          tag :"#{this.properties_tag || this.default_properties_tag}"
          namespace :"#{this.namespace}"
        end
      end

      def default_properties_tag
        :"#{tag}Pr"
      end

    end

    def properties_element
      @properties_element ||= self.class.properties_element.new
    end

    def properties_attributes
      properties_element.attributes
    end

    def render?
      return true unless defined?(super)
      render_properties? || super
    end

    def to_xml(xml)
      super(xml) do
        property_xml(xml)
        yield xml if block_given?
      end
    end

    def property_xml(xml)
      props = active_properties
      return unless render_properties? props

      properties_element.to_xml(xml) do
        props.each { |prop| prop.to_xml(xml) }
      end
    end

  private

    def properties
      self.class.properties
    end

    def active_properties
      properties.keys.map { |property| instance_variable_get("@#{property}") }.compact
    end

    def render_properties?(properties=active_properties)
      properties.any?(&:render?) || properties_attributes.any?
    end

    def properties_tag
      self.class.properties_tag || default_properties_tag
    end

    def default_properties_tag
      :"#{tag}Pr"
    end

  end
end
