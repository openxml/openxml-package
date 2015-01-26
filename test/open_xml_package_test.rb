require "test_helper"
require "fileutils"
require "set"


class OpenXmlPackageTest < ActiveSupport::TestCase
  attr_reader :package, :temp_file
  
  
  
  context "#add_part" do
    should "accept a path and a part" do
      package = OpenXml::Package.new
      package.add_part "PATH", OpenXml::Part.new
      assert_equal 1, package.parts.count
    end
  end
  
  
  
  context "Writing" do
    setup do
      @temp_file = expand_path "../tmp/test.zip"
      FileUtils.rm temp_file, force: true
    end
    
    context "Given a simple part" do
      setup do
        @package = OpenXml::Package.new
        package.add_part "content/document.xml", OpenXml::Parts::UnparsedPart.new(document_content)
      end
      
      should "write a valid zip file with the expected parts" do
        package.write_to temp_file
        assert File.exists?(temp_file), "Expected the file #{temp_file.inspect} to have been created"
        assert_equal %w{content/document.xml}, Zip::File.open(temp_file).entries.map(&:name)
      end
    end
  end
  
  
  
  context "Reading" do
    context "Given a sample Word document" do
      setup do
        @temp_file = expand_path "./support/sample.docx"
        @expected_contents = Set[
          "[Content_Types].xml",
          "_rels/.rels",
          "docProps/app.xml",
          "docProps/core.xml",
          "docProps/thumbnail.jpeg",
          "word/_rels/document.xml.rels",
          "word/document.xml",
          "word/fontTable.xml",
          "word/media/image1.png",
          "word/settings.xml",
          "word/styles.xml",
          "word/stylesWithEffects.xml",
          "word/theme/theme1.xml",
          "word/webSettings.xml" ]
      end
      
      context ".open" do
        setup do
          @package = OpenXml::Package.open(temp_file)
        end
        
        teardown do
          package.close
        end
        
        should "discover the expected parts" do
          assert_equal @expected_contents, package.parts.keys.to_set
        end
        
        should "read their content on-demand" do
          assert_equal web_settings_content, package.get_part("word/webSettings.xml").content
        end
      end
      
      context ".from_stream" do
        setup do
          @package = OpenXml::Package.from_stream(File.open(temp_file, "rb", &:read))
        end
        
        should "also discover the expected parts" do
          assert_equal @expected_contents, package.parts.keys.to_set
        end
        
        should "read their content" do
          assert_equal web_settings_content, package.get_part("word/webSettings.xml").content
        end
      end
    end
  end
  
  
  
private
  
  def document_content
    <<-STR
    <document>
      <body>Works!</body>
    </document>
    STR
  end
  
  def web_settings_content
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<w:webSettings xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" mc:Ignorable=\"w14\"><w:allowPNG/><w:doNotSaveAsSingleFile/></w:webSettings>"
  end
  
  def expand_path(path)
    File.expand_path(File.join(File.dirname(__FILE__), path))
  end
  
end
