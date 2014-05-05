require "test_helper"
require "fileutils"
require "digest"


class OpenXmlPackageTest < ActiveSupport::TestCase
  attr_reader :package, :temp_file
  
  
  
  context "#add_part" do
    should "accept a path and content" do
      package = OpenXmlPackage.new
      package.add_part "PATH", "CONTENT"
      assert_equal 1, package.parts.count
    end
    
    should "accept a part that responds to :path and :read" do
      package = OpenXmlPackage.new
      package.add_part OpenXmlPackage::Part.new("PATH", "CONTENT")
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
        @package = OpenXmlPackage.new
        package.add_part "content/document.xml", document_content
      end
      
      should "write a valid zip file with the expected parts" do
        package.write_to temp_file
        assert File.exists?(temp_file), "Expected the file #{temp_file.inspect} to have been created"
        assert_equal %w{content/document.xml}, Zip::File.open(temp_file).entries.map(&:name)
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
  
  def expand_path(path)
    File.expand_path(File.join(File.dirname(__FILE__), path))
  end
  
end
