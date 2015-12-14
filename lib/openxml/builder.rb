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
      @options = {
        with_xml: true,
        encoding: "utf-8"
      }.merge(options)
      @options[:with_xml] = !!@options[:with_xml] || @options[:standalone] == :yes

      @document = Ox::Document.new({version: "1.0"}.merge(@options))
      @parent = @document
      yield self if block_given?
    end

    def to_s
      Ox.dump @document, @options
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
