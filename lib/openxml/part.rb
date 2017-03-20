require "openxml/builder"

module OpenXml
  class Part

    def build_xml(options={})
      OpenXml::Builder.new(options) { |xml| yield xml }
    end

    def build_standalone_xml(&block)
      build_xml(standalone: :yes, &block)
    end

    def read
      to_xml.to_s
    end
    alias :content :read

    def to_xml
      raise NotImplementedError, "#{self.class} needs to implements to_xml"
    end

  end
end
