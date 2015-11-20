# Constructing a large XML document (5MB) with the Ox
# gem is about 4x faster than with Nokogiri and about
# 5x fater than with Builder.
#
# This class mimics the XML Builder DSL.
require "ox"

module OpenXml
  class Builder

    def initialize
      @document = Ox::Document.new(version: "1.0")
      @current = @document
      yield self if block_given?
    end

    def to_s
      Ox.dump @document
    end
    alias :to_xml :to_s

    def method_missing(tag_name, *args)
      new_element = Ox::Element.new(tag_name)
      attributes = args.extract_options!
      attributes.each do |key, value|
        new_element[key] = value
      end

      if block_given?
        begin
          was_current = @current
          @current = new_element
          yield self
        ensure
          @current = was_current
        end
      elsif value = args.first
        new_element << value.to_s
      end

      @current << new_element
    end

  end
end
