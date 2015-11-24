module OpenXml
  class Builder
    class Element < SimpleDelegator
      attr_reader :namespace
      attr_accessor :parent

      def initialize(*args)
        super Ox::Element.new(*args)
      end

      def []=(attribute, value)
        namespace_def = attribute.downcase.to_s.match /^xmlns(?:\:(?<prefix>.*))?$/
        add_namespace(namespace_def[:prefix], value.to_s) if namespace_def
        super
      end

      def namespace=(ns)
        @namespace = ns
        tag = name.match(/^(?:\w*?\:)?(?<tag>\w*)$/i)[:tag]
        self.value = "#{namespace.prefix}:#{tag}" if namespace.is_a? OpenXml::Builder::Namespace
        self.value = "#{namespace}:#{tag}" if namespace.is_a? String
      end

      def namespaces
        @namespaces ||= []
      end
      alias :namespace_definitions :namespaces

      def ancestors
        parents = [self]
        parents << parent.ancestors unless parent.nil? || !parent.respond_to?(:ancestors)
        parents.flatten
      end

    private

      def add_namespace(prefix, uri)
        namespaces << OpenXml::Builder::Namespace.new(prefix, uri)
      end

    end
  end
end
