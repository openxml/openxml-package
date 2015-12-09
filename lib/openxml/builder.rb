# Constructing a large XML document (5MB) with the Ox
# gem is about 4x faster than with Nokogiri and about
# 5x fater than with Builder.
#
# This class mimics the XML Builder DSL.
require "ox"
require "openxml/builder/document"
require "openxml/builder/element"
require "openxml/builder/namespace"

module OpenXml
  class Builder
    attr_reader :parent

    def initialize(options={})
      @options = {
        with_xml: true,
        encoding: "utf-8"
      }.merge(options)
      @options[:with_xml] = !!@options[:with_xml] || @options[:standalone] == :yes

      @document = OpenXml::Builder::Document.new({version: "1.0"}.merge(@options))
      @parent = @document
      yield self if block_given?
    end

    def to_s
      Ox.dump @document.__getobj__, @options
    end
    alias :to_xml :to_s

    # Adapted from Nokogiri's builder.rb
    def [](ns)
      if @parent != @document
        @ns = @parent.namespace_definitions.find { |x| x.prefix == ns.to_s }
      end
      return self if @ns

      @parent.ancestors.each do |a|
        next if a == @document
        @ns = a.namespace_definitions.find { |x| x.prefix == ns.to_s }
        return self if @ns
      end

      @ns = { :pending => ns.to_s }
      return self
    end

    def method_missing(tag_name, *args)
      new_element = OpenXml::Builder::Element.new(tag_name)
      new_element.parent = @parent
      attributes = extract_options!(args)
      attributes.each do |key, value|
        new_element[key] = value
      end

      # Adapted from Nokogiri's builder.rb
      if @ns.is_a? OpenXml::Builder::Namespace
        new_element.namespace = @ns
      elsif @ns.is_a? Hash
        new_element.namespace = new_element.namespace_definitions.find { |x| x.prefix == @ns[:pending] }
        raise ArgumentError, "Namespace #{@ns[:pending]} has not been defined" if new_element.namespace.nil?
      end

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
