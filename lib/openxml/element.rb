require "openxml/has_attributes"

module OpenXml
  class Element
    include HasAttributes

    class << self
      attr_reader :property_name
      attr_reader :namespace

      def tag(*args)
        @tag = args.first if args.any?
        @tag
      end

      def name(*args)
        @property_name = args.first if args.any?
        @name
      end

      def namespace(*args)
        @namespace = args.first if args.any?
        @namespace
      end

    end

    def tag
      self.class.tag || default_tag
    end

    def name
      self.class.property_name || default_name
    end

    def namespace
      ([self.class] + self.class.ancestors).select { |klass| klass.respond_to?(:namespace) }.map(&:namespace).find(&:itself)
    end

    def to_xml(xml)
      raise UndefinedNamespaceError, self.class unless namespace

      xml[namespace].public_send(tag, xml_attributes) do
        yield xml if block_given?
      end
    end

  private

    def default_tag
      (class_name[0, 1].downcase + class_name[1..-1]).to_sym
    end

    def default_name
      class_name.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end

    def class_name
      self.class.to_s.split(/::/).last
    end

  end

  class UndefinedNamespaceError < RuntimeError
    def initialize(klass)
      super "#{klass} does not define its namespace"
    end
  end
end
