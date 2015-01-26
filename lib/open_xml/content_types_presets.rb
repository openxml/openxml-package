module OpenXml
  class ContentTypesPresets

    def initialize
      @defaults, @overrides = [], []
    end

    def default(extension, content_type)
      defaults << {"Extension" => extension, "ContentType" => content_type}
    end

    def override(part_name, content_type)
      overrides << {"PartName" => part_name, "ContentType" => content_type}
    end

  end
end
