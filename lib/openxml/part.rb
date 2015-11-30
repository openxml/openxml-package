require "openxml/builder"

module OpenXml
  class Part

    def build_xml(options={})
      OpenXml::Builder.new(options) { |xml| yield xml }.to_xml
    end

    def build_standalone_xml(&block)
      build_xml({ standalone: :yes }, &block)
    end

    def read
      strip_whitespace to_xml
    end
    alias :content :read

    def to_xml
      raise NotImplementedError
    end

  protected

    def strip_whitespace(xml)
      xml.lines.map(&:strip).join
    end

  end
end
