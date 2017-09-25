module OpenXml
  module HasProperties

    class ChoiceGroupUniqueError < RuntimeError; end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def properties_tag(*args)
        @properties_tag = args.first if args.any?
        @properties_tag ||= nil
      end

      def value_property(name, as: nil, klass: nil, required: false, default_value: nil)
        attr_reader name

        properties[name] = (as || name).to_s
        required_properties[name] = default_value if required
        classified_name = properties[name].split("_").map(&:capitalize).join
        class_name = klass.to_s unless klass.nil?
        class_name ||= (to_s.split("::")[0...-2] + ["Properties", classified_name]).join("::")

        (choice_groups[current_group] ||= []).push(name) unless current_group.nil?

        class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(value)
          group_index = #{@current_group.inspect}
          ensure_unique_in_group(:#{name}, group_index) unless group_index.nil?
          instance_variable_set "@#{name}", #{class_name}.new(value)
        end
        CODE
      end

      def property(name, as: nil, klass: nil, required: false)
        properties[name] = (as || name).to_s
        required_properties[name] = true if required
        classified_name = properties[name].split("_").map(&:capitalize).join
        class_name = klass.to_s unless klass.nil?
        class_name ||= (to_s.split("::")[0...-2] + ["Properties", classified_name]).join("::")

        (choice_groups[current_group] ||= []).push(name) unless current_group.nil?

        class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}(*args)
          if instance_variable_get("@#{name}").nil?
            group_index = #{@current_group.inspect}
            ensure_unique_in_group(:#{name}, group_index) unless group_index.nil?
            instance_variable_set "@#{name}", #{class_name}.new(*args)
          end

          instance_variable_get "@#{name}"
        end
        CODE
      end

      def property_choice(required: false)
        warn "[WARNING] `required` parameter is not yet implemented for property_choice" if required
        @current_group = choice_groups.length
        yield
        @current_group = nil
      end

      def current_group
        @current_group ||= nil
      end

      def properties
        @properties ||= {}.tap do |props|
          props.merge!(superclass.properties) if superclass.respond_to?(:properties)
        end
      end

      def choice_groups
        @choice_groups ||= [].tap do |choices|
          choices.push(*superclass.choice_groups.map(&:dup)) if superclass.respond_to?(:choice_groups)
        end
      end

      def required_properties
        @required_properties ||= {}.tap do |props|
          props.merge!(superclass.required_properties) if superclass.respond_to?(:required_properties)
        end
      end
        end
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
        parent_klass = superclass.respond_to?(:properties_element) ? superclass.properties_element : OpenXml::Element
        @properties_element ||= Class.new(parent_klass) do
          tag :"#{this.properties_tag || this.default_properties_tag}"
          namespace :"#{this.namespace}"
        end
      end

      def default_properties_tag
        :"#{tag}Pr"
      end

    end

    def initialize(*_args)
      super
      build_required_properties
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

    def build_required_properties
      required_properties.each do |prop, default_value|
        public_send(:"#{prop}=", default_value) if respond_to? :"#{prop}="
        public_send(:"#{prop}")
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
      properties.any?(&:render?) || properties_attributes.keys.any? do |key|
        properties_element.instance_variable_defined?("@#{key}")
      end
    end

    def properties_tag
      self.class.properties_tag || default_properties_tag
    end

    def default_properties_tag
      :"#{tag}Pr"
    end

    def choice_groups
      self.class.choice_groups
    end

    def required_properties
      self.class.required_properties
    end

    def ensure_unique_in_group(name, group_index)
      other_names = (choice_groups[group_index] - [name])
      unique = other_names.all? { |other_name| !instance_variable_defined?("@#{other_name}") }
      message = "Property #{name} cannot also be set with #{other_names.join(", ")}."
      raise ChoiceGroupUniqueError, message unless unique
    end

  end
end
