require "openxml-package/version"
require "openxml/content_types_presets"
require "openxml/rubyzip_fix"
require "openxml/errors"
require "openxml/types"
require "openxml/parts"
require "zip"

module OpenXml
  class Package
    attr_reader :parts, :content_types, :rels



    class << self
      def content_types_presets
        @content_types_presets ||= OpenXml::ContentTypesPresets.new
      end

      def content_types(&block)
        content_types_presets.instance_eval &block
      end

      def open(path)
        if block_given?
          Zip::File.open(path) do |zipfile|
            yield new(zipfile)
          end
        else
          new Zip::File.open(path)
        end
      end

      def from_stream(stream)
        stream = StringIO.new(stream) if stream.is_a?(String)

        # Hack: Zip::Entry.read_c_dir_entry initializes
        # a new Zip::Entry by calling `io.path`. Zip::Entry
        # uses this to open the original zipfile; but in
        # this case, the StringIO _is_ the original.
        def stream.path
          self
        end

        zipfile = ::Zip::File.new("", true, true)
        zipfile.read_from_stream(stream)
        new(zipfile)
      end
    end



    def initialize(zipfile=nil)
      @zipfile = zipfile
      @parts = {}

      if zipfile
        read_zipfile!
      else
        set_defaults
      end
    end



    def add_part(path, part)
      @parts[path] = part
    end

    def get_part(path)
      @parts.fetch(path)
    end

    def type_of(path)
      raise Errors::MissingContentTypesPart, "We haven't yet read [ContentTypes].xml; but are reading #{path.inspect}" unless content_types
      content_types.of(path)
    end



    def close
      zipfile.close if zipfile
    end

    def write_to(path)
      File.open(path, "w") do |file|
        file.write to_stream.string
      end
    end
    alias :save :write_to

    def to_stream
      Zip::OutputStream.write_buffer do |io|
        parts.each do |path, part|
          io.put_next_entry path
          io.write part.content
        end
      end
    end

  private

    attr_reader :zipfile

    def read_zipfile!
      zipfile.entries.each do |entry|
        path, part = entry.name, Parts::UnparsedPart.new(entry)
        add_part path, case path
        when "[Content_Types].xml" then @content_types = Parts::ContentTypes.parse(part.content)
        when "_rels/.rels" then @rels = Parts::Rels.parse(part.content)
        else part_for(path, type_of(path), part)
        end
      end
    end

  protected

    def set_defaults
      presets = self.class.content_types_presets
      @content_types = Parts::ContentTypes.new(presets.defaults, presets.overrides)
      add_part "[Content_Types].xml", content_types

      @rels = Parts::Rels.new
      add_part "_rels/.rels", rels
    end

    def part_for(path, content_type, part)
      case content_type
      when Types::RELATIONSHIPS then Parts::Rels.parse(part.content)
      else part
      end
    end

  end
end
