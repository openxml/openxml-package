require "test_helper"
require "openxml/has_attributes"

class HasAttributesTest < Minitest::Test
  context "ClassMethod.attribute" do
    should "define a reader method for the attribute" do
      element = class_with_attribute :an_attribute
      assert element.new.respond_to? :an_attribute
    end

    should "define a writer method for the attribute" do
      element = class_with_attribute :an_attribute
      assert element.new.respond_to? :an_attribute=
    end

    should "be named by its camelCased version if no displays_as given" do
      element = class_with_attribute :an_attribute
      assert_equal :anAttribute, element.attributes[:an_attribute][0]
    end

    should "be named by its displays_as property if given" do
      element = class_with_attribute :an_attribute, displays_as: :theAttr
      assert_equal :theAttr, element.attributes[:an_attribute][0]
    end

    context "in a with_namespace block" do
      should "use the provided namespace" do
        element = Class.new {
          include OpenXml::HasAttributes
          with_namespace :a_namespace do
            attribute :an_attribute
          end
        }
        assert_equal :a_namespace, element.attributes[:an_attribute][1]
      end
    end
  end

  context "validations" do
    should "raise an ArgumentError if the name is disallowed" do
      assert_raises ArgumentError do
        class_with_attribute :name
      end
    end

    should "raise an ArgumentError if the value does not match the expects parameter" do
      assert_raises ArgumentError do
        element = class_with_attribute :an_attribute, expects: :integer
        element.new.an_attribute = "A String"
      end
    end

    should "raise an ArgumentError if the value is not one of the enumerated values" do
      assert_raises ArgumentError do
        element = class_with_attribute :an_attribute, one_of: %i{ left right }
        element.new.an_attribute = :start
      end
    end

    should "raise an ArgumentError if the value is not in the given range" do
      assert_raises ArgumentError do
        element = class_with_attribute :an_attribute, in_range: 1...9000
        element.new.an_attribute = 9001
      end
    end

    should "raise an ArgumentError if the value fails the regex match" do
      assert_raises ArgumentError do
        element = class_with_attribute :an_attribute, matches: /^[a-f0-9]+$/i
        element.new.an_attribute = "AGGPPTAAGGTT"
      end
    end
  end

private

  def class_with_attribute(attr_name, **args)
    Class.new {
      include OpenXml::HasAttributes
      attribute attr_name, **args

      def name
        "element"
      end
    }
  end

end
