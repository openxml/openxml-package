require "test_helper"

class RelsTest < Minitest::Test
  context "with no defaults" do
    should "be empty" do
      assert OpenXml::Parts::Rels.new.empty?
    end
  end

  context "#to_xml" do
    context "given a document with an external hyperlink" do
      should "write the TargetMode attribute of the Relationship element" do
        path = File.expand_path "../support/external_hyperlink.docx", __FILE__
        OpenXml::Package.open(path) do |package|
          part = package.parts["word/_rels/document.xml.rels"]
          assert_match /<Relationship Id=".+" Target="http:\/\/example.com" TargetMode="External"/, part.to_xml.to_s
        end
      end
    end
  end
end
