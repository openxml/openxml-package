module OpenXml
  module HasAttributes

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def attribute(name, expects: nil, one_of: nil, in_range: nil, displays_as: nil, namespace: nil, matches: nil, deprecated: false)
        bad_names = %w{ tag name namespace properties_tag }
        raise ArgumentError if bad_names.member? name.to_s

        attr_reader name

        define_method "#{name}=" do |value|
          valid_in?(value, one_of) unless one_of.nil?
          send(expects, value) unless expects.nil?
          matches?(value, matches) unless matches.nil?
          in_range?(value, in_range) unless in_range.nil?
          instance_variable_set "@#{name}", value
        end

        camelized_name = name.to_s.gsub(/_([a-z])/i) { $1.upcase }.to_sym
        attributes[name] = [displays_as || camelized_name, namespace || @attribute_namespace]
      end

      def attributes
        @attributes ||= {}
      end

      def with_namespace(namespace, &block)
        @attribute_namespace = namespace
        instance_eval(&block)
      end

    end

    def render?
      attributes.keys.map(&method(:send)).any?
    end

    def attributes
      self.class.attributes
    end

  private

    def xml_attributes
      attributes.each_with_object({}) do |(name, options), attrs|
        display, namespace = options
        value = send(name)
        attr_name = "#{namespace}:#{display}"
        attr_name = display.to_s if namespace.nil?
        attrs[attr_name] = value unless value.nil?
      end
    end

    def boolean(value)
      message = "Invalid #{name}: frame must be true or false"
      raise ArgumentError, message unless [true, false].member? value
    end

    def hex_color(value)
      message = "Invalid #{name}: must be :auto or a hex color, e.g. 4F1B8C"
      raise ArgumentError, message unless value == :auto || value =~ /^[0-9A-F]{6}$/
    end

    def hex_digit(value)
      message = "Invalid #{name}: must be a two-digit hex number, e.g. BF"
      raise ArgumentError, message unless value =~ /^[0-9A-F]{2}$/
    end

    def hex_digit_4(value)
      message = "Invalid #{name}: must be a four-digit hex number, e.g. BF12"
      raise ArgumentError, message unless value =~ /^[0-9A-F]{4}$/
    end

    def long_hex_number(value)
      message = "Invalid #{name}: must be an eight-digit hex number, e.g., FFAC0013"
      raise ArgumentError, message unless value =~ /^[0-9A-F]{8}$/
    end

    def hex_string(value)
      message = "Invalid #{name}: must be a string of hexadecimal numbers, e.g. FFA23C6E"
      raise ArgumentError, message unless value =~ /^[0-9A-F]+$/
    end

    def integer(value)
      message = "Invalid #{name}: must be an integer"
      raise ArgumentError, message unless value.is_a?(Integer)
    end

    def positive_integer(value)
      message = "Invalid #{name}: must be a positive integer"
      raise ArgumentError, message unless value.is_a?(Integer) && value >= 0
    end

    def string(value)
      message = "Invalid #{name}: must be a string"
      raise ArgumentError, message if !value.is_a?(String) || value.length.zero?
    end

    def in_range?(value, range)
      message = "Invalid #{name}: must be a number between #{range.begin} and #{range.end}"
      raise ArgumentError, message unless range.include?(value.to_i)
    end

    def percentage(value)
      message = "Invalid #{name}: must be a percentage"
      raise ArgumentError, message unless value.is_a?(String) && value =~ /-?[0-9]+(\.[0-9]+)?%/ # Regex supplied in sec. 22.9.2.9 of Office Open XML docs
    end

    def on_or_off(value)
      valid_in? value, %i{ on off }
    end

    def valid_in?(value, list)
      message = "Invalid #{name}: must be one of #{list} (was #{value.inspect})"
      raise ArgumentError, message unless list.member?(value)
    end

    def matches?(value, regexp)
      message = "Value does not match #{regexp}"
      raise ArgumentError, message unless value =~ regexp
    end

  end
end
