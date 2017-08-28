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
    end

    def to_xml(xml)
      super(xml) do
        property_xml(xml)
        yield xml if block_given?
      end
    end

    def property_xml(xml)
      props = properties.keys.map(&method(:send)).compact
      return if props.none?(&:render?)

      xml[namespace].public_send(properties_tag) {
        props.each { |prop| prop.to_xml(xml) }
      }
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

  end
end
