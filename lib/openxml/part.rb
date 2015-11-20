require "nokogiri"
require "openxml/builder"

module OpenXml
  class Part
    include ::Nokogiri

    def build_xml
      OpenXml::Builder.new { |xml| yield xml }.to_xml
    end

    def build_standalone_xml(&block)
      "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>" + build_xml(&block)
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
