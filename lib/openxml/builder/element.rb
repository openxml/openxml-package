require "delegate"

module OpenXml
  class Builder
    class Element < SimpleDelegator
      attr_reader :namespace

      def initialize(*args)
        super Ox::Element.new(*args)
      end

      def []=(attribute, value)
        namespace_def = attribute.downcase.to_s.match(/^xmlns(?:\:(?<prefix>.*))?$/)
        namespaces << namespace_def[:prefix].to_sym if namespace_def && namespace_def[:prefix]
        super
      end

      def namespace=(ns)
        @namespace = ns.to_sym if ns
        tag = name.match(/^(?:\w*?\:)?(?<tag>\w*)$/i)[:tag]
        self.value = "#{namespace}:#{tag}" if namespace
      end

      def namespaces=(ns)
        @namespaces = Array(ns)
      end

      def namespaces
        @namespaces ||= []
      end
      alias :namespace_definitions :namespaces

    end
  end
end
