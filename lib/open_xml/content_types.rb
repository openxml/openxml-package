module OpenXml
  class ContentTypes << Part
    attr_reader :defaults, :overrides

    def initialize(defaults, overrides)
      @defaults = defaults
      @overrides = overrides
    end

    def default(extension, content_type)
      defaults << {"Extension" => extension, "ContentType" => content_type}
    end

    def override(part_name, content_type)
      overrides << {"PartName" => part_name, "ContentType" => content_type}
    end

    def to_xml
      build_xml do |xml|
        xml.Types(xmlns: "http://schemas.openxmlformats.org/package/2006/content-types") {
          defaults.each { |default| xml.Default(default) }
          overrides.each { |override| xml.Override(override) }
        }
      end
    end

  end
end
