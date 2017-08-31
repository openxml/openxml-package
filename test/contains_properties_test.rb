require "test_helper"
require "openxml/element"
require "openxml/properties"
require "openxml/contains_properties"

class ContainsPropertiesTest < Minitest::Test
  should "allow properties to be rendered as direct children" do
    element = Class.new(OpenXml::Element) do
      include OpenXml::ContainsProperties
      tag :bodyPr
      namespace :a

      value_property :string_property
    end.new
    element.string_property = "A Value"

    rendered_xml = build(element)
    refute_match /a:bodyPrPr/, rendered_xml
    assert_match /a:stringProperty val="A Value"/, rendered_xml
  end

private

  def build(element)
    builder = Nokogiri::XML::Builder.new
    builder.document("xmlns:a" => "http://microsoft.com") do |xml|
      element.to_xml(xml)
    end
    builder.to_xml
  end

end
