require "test_helper"

class ElementTest < ActiveSupport::TestCase
  attr_reader :element

  setup do
    @element = OpenXml::Builder::Element.new("tag")
  end

  context "The element" do
    should "correctly assign attributes" do
      element[:attribute] = "value"
      element["namespaced:attribute"] = "value"
      dump = Ox.dump(element.__getobj__)
      assert_equal "\n<tag attribute=\"value\" namespaced:attribute=\"value\"/>\n", dump
    end

    should "parse out available namespace prefixes from namespace definition attributes" do
      nsdef_prefix = "xmlns:namespace"
      nsdef_uri = "http://schema.somenamespace.org/"
      element[nsdef_prefix] = nsdef_uri
      assert_equal [:namespace], element.namespaces
    end

    should "only parse namespace definition attributes with a prefix" do
      element["xmlns"] = "http://schema.somenamespace.org/"
      assert element.namespaces.empty?
    end

    should "correctly use a namespace prefix" do
      element.namespace = "namespace"
      dump = Ox.dump(element.__getobj__)
      assert_equal "\n<namespace:tag/>\n", dump
    end
  end


end
