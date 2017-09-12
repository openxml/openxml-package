# Constructing a large XML document (5MB) with the Ox
# gem is about 4x faster than with Nokogiri and about
# 5x fater than with Builder.
#
# This class mimics the XML Builder DSL.
require "ox"
require "openxml/builder/element"

module OpenXml
  class Builder
    attr_reader :parent

    def initialize(options={})
      @to_s_options = { with_xml: true }

      @ns = nil
      @document = Ox::Document.new(
        encoding: "UTF-8",
        version: "1.0",
        standalone: options[:standalone])
      @parent = @document
      yield self if block_given?
    end

    def to_s(args={})
      options = @to_s_options

      # Unless we would like to debug the files,
      # don't add whitespace during generation.
      options = options.merge(indent: -1) unless args[:debug]

      Ox.dump(@document, options).strip
    end
    alias :to_xml :to_s

    def [](ns)
      @ns = ns.to_sym if ns
      return self
    end

    def method_missing(tag_name, *args)
      new_element = OpenXml::Builder::Element.new(tag_name)
      attributes = extract_options!(args)
      attributes.each do |key, value|
        new_element[key] = value
      end

      new_element.namespace = @ns
      @ns = nil

      if block_given?
        begin
          was_current = @parent
          @parent = new_element
          yield self
        ensure
          @parent = was_current
        end
      elsif value = args.first
        new_element << value.to_s
      end

      @parent << new_element.__getobj__
    end

  private

    def extract_options!(args)
      if args.last.is_a?(Hash) && args.last.instance_of?(Hash)
        args.pop
      else
        {}
      end
    end

  end
end
