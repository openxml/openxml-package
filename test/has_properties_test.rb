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
          property :polymorphic_property
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

      should "allow a parameter to be passed in to initialize on access" do
        an_element = element.new
        an_element.polymorphic_property(:tagTwo)
        assert_equal an_element.polymorphic_property.tag, :tagTwo
      end
    end

    context ".property_choice" do
      setup do
        @element = Class.new do
          include OpenXml::HasProperties

          property_choice do
            value_property :property_one, as: :boolean_property
            property :property_two, as: :complex_property
          end
        end
      end

      should "raise an exception when attempting to use more than one property in the group" do
        an_element = element.new
        assert_raises OpenXml::HasProperties::ChoiceGroupUniqueError do
          an_element.property_one = true
          an_element.property_two
        end

        another_element = element.new
        assert_raises OpenXml::HasProperties::ChoiceGroupUniqueError do
          another_element.property_two
          another_element.property_one = true
        end
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

        assert_match(/<w:pPr>/, xml(an_element))
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

      assert_match(/w:pPr b="true"/, xml(element))
    end
  end

  context "a subclass of a class that has included HasProperties" do
    should "inherit the properties of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        value_property :boolean_property
      end
      child = Class.new(parent)

      assert_equal %i{ boolean_property }, child.new.send(:properties).keys
    end

    should "not modify the properties of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        value_property :boolean_property
      end
      child = Class.new(parent) do
        value_property :another_bool, as: :boolean_property
      end

      assert_equal %i{ boolean_property }, parent.properties.keys
      assert_equal %i{ another_bool boolean_property }, child.new.send(:properties).keys.sort
    end

    should "inherit the required properties of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        property :complex_property, required: true
      end
      child = Class.new(parent)

      assert_equal %i{ complex_property }, child.new.send(:required_properties)
    end

    should "not modify the required properties of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        property :complex_property, required: true
      end
      child = Class.new(parent) do
        property :another_one, as: :complex_property, required: true
      end

      assert_equal %i{ complex_property }, parent.required_properties
      assert_equal %i{ another_one complex_property }, child.new.send(:required_properties).sort
    end

    should "inherit the accessors of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        value_property :boolean_property
      end
      child = Class.new(parent).new

      assert child.respond_to?(:boolean_property=), "Should respond to property assignment"
      assert child.respond_to?(:boolean_property), "Should respond to property accessor"
    end

    should "inherit the choice groups of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        property_choice do
          value_property :boolean_property
        end
      end
      child = Class.new(parent).new

      assert_equal 1, child.send(:choice_groups).count
      assert_equal %i{ boolean_property }, child.send(:choice_groups).first
    end

    should "not modify the choice groups of its superclass" do
      parent = Class.new do
        include OpenXml::HasProperties
        property_choice do
          value_property :boolean_property
        end
      end
      child = Class.new(parent) do
        property_choice do
          value_property :another_boolean, as: :boolean_property
        end
      end

      assert_equal 1, parent.choice_groups.count
      assert_equal %i{ boolean_property }, parent.choice_groups.first
      assert_equal 2, child.choice_groups.count
      assert_equal %i{ boolean_property }, child.choice_groups.first
      assert_equal %i{ another_boolean }, child.choice_groups.last
    end

    should "inherit the attributes of the properties tag of its superclass" do
      parent = Class.new(OpenXml::Element) do
        include OpenXml::HasProperties
        properties_attribute :an_attribute
      end
      child = Class.new(parent) do
        tag :p
      end

      assert_equal %i{ an_attribute }, child.new.properties_attributes.keys
    end

    should "not modify the attributes of the properties tag of its superclass" do
      parent = Class.new(OpenXml::Element) do
        include OpenXml::HasProperties
        tag :q
        properties_attribute :an_attribute
      end
      child = Class.new(parent) do
        tag :p
        properties_attribute :another_attribute
      end

      assert_equal %i{ an_attribute }, parent.new.properties_attributes.keys
      assert_equal %i{ an_attribute another_attribute }, child.new.properties_attributes.keys.sort
    end
  end

  context "#build_required_properties" do
    setup do
      @element = Class.new do
        include OpenXml::HasProperties
        property :property_haver_property, required: true
        value_property :boolean_property, required: true

        def default_property_value_for(prop)
          default_value_calls << prop
          true
        end

        def default_value_calls
          @default_value_calls ||= []
        end
      end
    end

    should "instantiate each required property" do
      an_element = element.new
      an_element.build_required_properties
      assert an_element.instance_variable_defined?(:"@property_haver_property")
      assert an_element.instance_variable_defined?(:"@boolean_property")
    end

    should "call #build_required_properties in turn on each required property" do
      an_element = element.new
      mock = MiniTest::Mock.new
      mock.expect :build_required_properties, nil

      OpenXml::Properties::PropertyHaverProperty.stub :new, mock do
        an_element.build_required_properties
      end

      assert mock.verify
    end

    should "call #default_property_value_for with each required value property" do
      an_element = element.new
      assert_equal 0, an_element.default_value_calls.count, "Expected default_value_calls to be empty initially"
      an_element.build_required_properties
      assert_equal %i{ boolean_property }, an_element.default_value_calls
    end
  end

private

  def xml(element)
    builder = Nokogiri::XML::Builder.new
    builder.document("xmlns:w" => "http://microsoft.com") do |xml|
      element.to_xml(xml)
    end
    builder.to_xml
  end

end

module OpenXml
  module Properties

    class PolymorphicProperty < BaseProperty
      tag_is_one_of %i{ tagOne tagTwo }

    end

    class PropertyHaverProperty < ComplexProperty
      include OpenXml::HasProperties

    end

  end
end
