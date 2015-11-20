module OpenXml
  class ContentTypesPresets
    attr_reader :defaults, :overrides

    def initialize
      @defaults, @overrides = {}, {}
    end

    def default(extension, content_type)
      defaults[extension] = content_type
    end

    def override(part_name, content_type)
      overrides[part_name] = content_type
    end

  end
end
