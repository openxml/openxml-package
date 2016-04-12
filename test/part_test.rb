require "test_helper"
require "fileutils"
require "set"

class PartTest < ActiveSupport::TestCase
  attr_reader :part, :builder



  context "Building" do
    setup do
      @part = OpenXml::Part.new
    end

    context "Given simple xml for one part" do
      setup do
        @builder = @part.build_xml do |xml|
          xml.document do |xml|
            2.times { xml.child(attribute: "value", other_attr: "other value") }
          end
        end
      end

      should "build the expected xml" do
        assert_equal basic_xml, builder.to_s(debug: true)
      end
    end

    context "Given namespaced xml for one part" do
      setup do
        @builder = @part.build_xml do |xml|
          xml.document("xmlns:ns" => "some:namespace:uri") do
            2.times { xml["ns"].child(attribute: "value", other_attr: "other value") }
          end
        end
      end

      should "build the expected xml" do
        assert_equal namespaced_xml, builder.to_s(debug: true)
      end
    end

    context "For a standalone XML element" do
      setup do
        @builder = @part.build_standalone_xml do |xml|
          xml.document do
            xml.child(attribute: "value", other_attr: "other value")
          end
        end
      end

      should "build the expected xml" do
        assert_equal standalone_xml, builder.to_s(debug: true)
      end
    end
  end



private

  def basic_xml
    <<-STR.strip
<?xml version="1.0" encoding="utf-8"?>
<document>
  <child attribute="value" other_attr="other value"/>
  <child attribute="value" other_attr="other value"/>
</document>
    STR
  end

  def namespaced_xml
    <<-STR.strip
<?xml version="1.0" encoding="utf-8"?>
<document xmlns:ns="some:namespace:uri">
  <ns:child attribute="value" other_attr="other value"/>
  <ns:child attribute="value" other_attr="other value"/>
</document>
    STR
  end

  def standalone_xml
    <<-STR.strip
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<document>
  <child attribute="value" other_attr="other value"/>
</document>
    STR
  end

end
