require "test_helper"

class ContentTypesTest < ActiveSupport::TestCase
  attr_reader :content_types

  WORDPROCESSING_DOCUMENT_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"

  setup do
    @content_types = OpenXml::Parts::ContentTypes.new(
      {"xml" => OpenXml::Types::XML, "rels" => OpenXml::Types::RELATIONSHIPS},
      {"word/document.xml" => WORDPROCESSING_DOCUMENT_TYPE})
  end


  context "Given a path without an override" do
    should "identify the content type from its extension" do
      assert_equal OpenXml::Types::XML, content_types.of("content/some.xml")
    end
  end

  context "Given a path with an override" do
    should "identify the content type from its path" do
      assert_equal WORDPROCESSING_DOCUMENT_TYPE, content_types.of("word/document.xml")
    end
  end

  context "Given a path with an unrecognized extension" do
    should "be nil" do
      assert_equal nil, content_types.of("img/screenshot.jpg")
    end
  end


end
