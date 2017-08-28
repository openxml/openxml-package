require "test_helper"
require "openxml/element"
require "openxml/has_properties"

class HasPropertiesTest < Minitest::Test
  attr_reader :element

  context "When HasProperties is included," do
    context ".value_property" do
      setup do
        @element = Class.new do
          include OpenXml::HasProperties

          value_property :value_property
        end
      end

      should "generate accessor methods for the property" do
        an_element = element.new
        assert an_element.respond_to? :value_property
        assert an_element.respond_to? :value_property=
      end

      should "instantiate the property on assignment of a value" do
        an_element = element.new
        an_element.value_property = "A Value"
        an_element.value_property.is_a?(OpenXml::Properties::ValueProperty)
      end
    end

    context ".property" do
      setup do
        @element = Class.new do
          include OpenXml::HasProperties

          property :some_property
        end
      end

      should "generate a reader method only for the property" do
        an_element = element.new
        assert an_element.respond_to? :some_property
      end

      should "instantiate the property on first access" do
        an_element = element.new
        refute an_element.instance_variable_get("@some_property")
        assert an_element.some_property.is_a?(OpenXml::Properties::SomeProperty)
      end
    end

    context "#to_xml" do
      setup do
        base_class = Class.new do
          attr_reader :namespace

          def to_xml(xml)
            yield xml if block_given?
            xml
          end
        end

        @element = Class.new(base_class) do
          include OpenXml::HasProperties
          value_property :value_property

          def tag
            "p"
          end
        end
      end

      should "generate the property tag as part of to_xml" do
        an_element = element.new
        an_element.value_property = true

        builder = Nokogiri::XML::Builder.new
        an_element.to_xml(builder)

        assert %r{<pPr/>} =~ builder.to_xml
      end

      should "call to_xml on each property" do
        builder = Nokogiri::XML::Builder.new
        mock = MiniTest::Mock.new
        def mock.render?; true; end
        mock.expect(:to_xml, nil, [ builder ])

        OpenXml::Properties::ValueProperty.stub :new, mock do
          an_element = element.new
          an_element.value_property = true

          an_element.to_xml(builder)
          mock.verify
        end
      end
    end
  end

end



module OpenXml
  module Properties

    class SomeProperty

      def to_xml(builder)
        yield builder if block_given?
        builder
      end

    end

    class ValueProperty < SomeProperty

      def initialize(value)
        raise ArgumentError unless value
        @value = value
      end

      def render?
        !!@value
      end

    end

  end
end
