require "test_helper"
require "openxml/has_children"

class HasChildrenTest < Minitest::Test
  attr_reader :element

  context "with HasChildren included" do
    setup do
      base_class = Class.new {
        def to_xml(xml)
          yield xml if block_given?
          xml
        end

        def render?
          false
        end
      }

      @element = Class.new(base_class) {
        include OpenXml::HasChildren
      }.new
    end

    should "append children using the shovel operator" do
      assert_equal 0, element.children.count
      element << :child_placeholder
      assert_equal 1, element.children.count
    end

    should "enable rendering if there are any children" do
      refute element.render?
      element.push :child_placeholder
      assert element.render?
    end

    should "call to_xml on all of its children" do
      child = MiniTest::Mock.new
      child.expect :to_xml, "xml", %w{ xml }
      element << child
      element.to_xml "xml"
      child.verify
    end
  end

end
