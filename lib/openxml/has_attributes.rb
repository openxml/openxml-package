require "openxml/unmet_requirement"

module OpenXml
  module HasAttributes

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      RESERVED_NAMES = %w{ tag name namespace properties_tag }.freeze

      def attribute(name, expects: nil, one_of: nil, in_range: nil, displays_as: nil, namespace: nil, matches: nil, validation: nil, required: false, deprecated: false)
        raise ArgumentError if RESERVED_NAMES.member? name.to_s

        required_attributes.push(name) if required

        attr_reader name

        define_method "#{name}=" do |value|
          valid_in?(value, one_of) unless one_of.nil?
          send(expects, value) unless expects.nil?
          matches?(value, matches) unless matches.nil?
          in_range?(value, in_range) unless in_range.nil?
          validation.call(value) if validation.respond_to? :call
          instance_variable_set "@#{name}", value
        end

        camelized_name = name.to_s.gsub(/_([a-z])/i) { $1.upcase }.to_sym
        attributes[name] = [displays_as || camelized_name, namespace || attribute_namespace]
      end

      def attributes
        @attributes ||= {}.tap do |attrs|
          if superclass.respond_to?(:attributes)
            superclass.attributes.each do |key, value|
              attrs[key] = value.dup
            end
          end
        end
      end

      def required_attributes
        @required_attributes ||= [].tap do |attrs|
          attrs.push(*superclass.required_attributes) if superclass.respond_to?(:required_attributes)
        end
      end

      def with_namespace(namespace, &block)
        @attribute_namespace = namespace
        instance_eval(&block)
      end

      def attribute_namespace
        @attribute_namespace ||= nil
      end

    end

    def render?
      attributes.keys.map(&method(:send)).any?
    end

    def attributes
      self.class.attributes
    end

    def required_attributes
      self.class.required_attributes
    end

  private

    def xml_attributes
      ensure_required_attributes_set
      attributes.each_with_object({}) do |(name, options), attrs|
        display, namespace = options
        value = send(name)
        attr_name = "#{namespace}:#{display}"
        attr_name = display.to_s if namespace.nil?
        attrs[attr_name] = value unless value.nil?
      end
    end

    def ensure_required_attributes_set
      unset_attributes = required_attributes.reject do |attr|
        instance_variable_defined?("@#{attr}")
      end
      return if unset_attributes.empty?

      raise OpenXml::UnmetRequirementError, "Required attribute(s) #{unset_attributes.join(", ")} have not been set"
    end

    def boolean(value)
      return if [true, false].member? value
      raise ArgumentError, "Invalid #{name}: frame must be true or false"
    end

    def hex_color(value)
      return if value == :auto || value =~ /^[0-9A-F]{6}$/
      raise ArgumentError, "Invalid #{name}: must be :auto or a hex color, e.g. 4F1B8C"
    end

    def hex_digit(value)
      return if value =~ /^[0-9A-F]{2}$/
      raise ArgumentError, "Invalid #{name}: must be a two-digit hex number, e.g. BF"
    end

    def hex_digit_4(value)
      return if value =~ /^[0-9A-F]{4}$/
      raise ArgumentError, "Invalid #{name}: must be a four-digit hex number, e.g. BF12"
    end

    def long_hex_number(value)
      return if value =~ /^[0-9A-F]{8}$/
      raise ArgumentError, "Invalid #{name}: must be an eight-digit hex number, e.g., FFAC0013"
    end

    def hex_string(value)
      return if value =~ /^[0-9A-F]+$/
      raise ArgumentError, "Invalid #{name}: must be a string of hexadecimal numbers, e.g. FFA23C6E"
    end

    def integer(value)
      return if value.is_a?(Integer)
      raise ArgumentError, "Invalid #{name}: must be an integer"
    end

    def positive_integer(value)
      return if value.is_a?(Integer) && value >= 0
      raise ArgumentError, "Invalid #{name}: must be a positive integer"
    end

    def string(value)
      return if value.is_a?(String) && value.length > 0
      raise ArgumentError, "Invalid #{name}: must be a string"
    end

    def string_or_blank(value)
      return if value.is_a?(String)
      raise ArgumentError, "Invalid #{name}: must be a string, even if the string is empty"
    end

    def in_range?(value, range)
      return if range.include?(value.to_i)
      raise ArgumentError, "Invalid #{name}: must be a number between #{range.begin} and #{range.end}"
    end

    def percentage(value)
      return if value.is_a?(String) && value =~ /-?[0-9]+(\.[0-9]+)?%/ # Regex supplied in sec. 22.9.2.9 of Office Open XML docs
      raise ArgumentError, "Invalid #{name}: must be a percentage"
    end

    def on_or_off(value)
      valid_in? value, %i{ on off }
    end

    def valid_in?(value, list)
      return if list.member?(value)
      raise ArgumentError, "Invalid #{name}: must be one of #{list} (was #{value.inspect})"
    end

    def matches?(value, regexp)
      return if value =~ regexp
      raise ArgumentError, "Value does not match #{regexp}"
    end

  end
end
