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

      def omit_properties_tag(*args)
        @omit_properties_tag = args.first if args.any?
        @omit_properties_tag
      end
      alias omit_properties_tag? omit_properties_tag

      def properties_are_children
        omit_properties_tag(true)
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
        def #{name}
          if instance_variable_get("@#{name}").nil?
            instance_variable_set "@#{name}", Properties::#{class_name}.new
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

      def mutually_exclusive(*property_names)
        property_names.each do |property_name|
          alias_method :"__set_#{property_name}", :"#{property_name}="
          define_method "#{property_name}=" do |value|
            message = "Only one of #{property_names.join(", ")} can be set at a time"
            other_properties = (property_names - [ property_name ])
            values_nil = other_properties.map { |name| public_send(name).nil? } + [ value.nil? ]
            raise ArgumentError, message unless values_nil.one?(&:!)
            public_send(:"__set_#{property_name}", value)
          end
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

    def to_xml(xml)
      super(xml) do
        property_xml(xml)
        yield xml if block_given?
      end
    end

    def property_xml(xml)
      props = properties.keys.map(&method(:send)).compact
      return if props.none?(&:render?) && properties_attributes.none?

      if omit_properties_tag?
        props.each { |prop| prop.to_xml(xml) }
      else
        properties_element.to_xml(xml) do
          props.each { |prop| prop.to_xml(xml) }
        end
      end
    end

  private

    def properties
      self.class.properties
    end

    def properties_tag
      self.class.properties_tag || default_properties_tag
    end

    def default_properties_tag
      :"#{tag}Pr"
    end

    def omit_properties_tag?
      self.class.omit_properties_tag?
    end

  end
end
