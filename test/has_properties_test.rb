require "test_helper"
require "openxml/element"
require "openxml/properties"
require "openxml/has_properties"

class HasPropertiesTest < Minitest::Test
  attr_reader :element

  context "When HasProperties is included," do
    context ".value_property" do
      setup do
        @element = Class.new do
          include OpenXml::HasProperties

          value_property :string_property
        end
      end

      should "generate accessor methods for the property" do
        an_element = element.new
        assert an_element.respond_to? :string_property
        assert an_element.respond_to? :string_property=
      end

      should "instantiate the property on assignment of a value" do
        an_element = element.new
        an_element.string_property = "A Value"
        an_element.string_property.is_a?(OpenXml::Properties::StringProperty)
      end
    end

    context ".property" do
      setup do
        @element = Class.new do
          include OpenXml::HasProperties

          property :complex_property
        end
      end

      should "generate a reader method only for the property" do
        an_element = element.new
        assert an_element.respond_to? :complex_property
      end

      should "instantiate the property on first access" do
        an_element = element.new
        refute an_element.instance_variable_get("@complex_property")
        assert an_element.complex_property.is_a?(OpenXml::Properties::ComplexProperty)
      end
    end

    context "#to_xml" do
      setup do
        base_class = Class.new do
          def self.namespace
            :w
          end

          def namespace
            self.class.namespace
          end

          def to_xml(xml)
            xml.public_send(tag, "xmlns:w" => "http://microsoft.com") do
              yield xml if block_given?
            end
          end
        end

        @element = Class.new(base_class) do
          include OpenXml::HasProperties
          value_property :boolean_property

          def self.tag
            "p"
          end

          def tag
            self.class.tag
          end
        end
      end

      should "generate the property tag as part of to_xml" do
        an_element = element.new
        an_element.boolean_property = true

        builder = Nokogiri::XML::Builder.new
        an_element.to_xml(builder)

        assert_match /<w:pPr>/, builder.to_xml
      end

      should "call to_xml on each property" do
        builder = Nokogiri::XML::Builder.new
        mock = MiniTest::Mock.new
        def mock.render?; true; end
        mock.expect(:to_xml, nil, [ builder ])

        OpenXml::Properties::BooleanProperty.stub :new, mock do
          an_element = element.new
          an_element.boolean_property = true

          an_element.to_xml(builder)
          mock.verify
        end
      end
    end

    should "allow attributes to be set on the properties tag" do
      element = Class.new(OpenXml::Element) do
        include OpenXml::HasProperties
        tag :p
        namespace :w

        properties_attribute :bold, displays_as: :b, expects: :boolean
      end.new
      element.bold = true

      builder = Nokogiri::XML::Builder.new
      builder.document("xmlns:w" => "http://microsoft.com") do |xml|
        element.to_xml(xml)
      end

      assert_match /w:pPr b="true"/, builder.to_xml
    end
  end

end
