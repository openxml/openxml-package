require "test_helper"
require "fileutils"
require "digest"


class OpenXmlPackageTest < ActiveSupport::TestCase
  attr_reader :package, :temp_file
  
  context "Writing" do
    setup do
      @temp_file = expand_path "../tmp/test.zip"
      FileUtils.rm temp_file, force: true
    end
    
    context "Given a simple part" do
      setup do
        @package = OpenXmlPackage.new
        package.add_part "content/document.xml", a_part
      end
      
      should "write a valid zip file with the expected parts" do
        package.write_to temp_file
        assert File.exists?(temp_file), "Expected the file #{temp_file.inspect} to have been created"
        assert_equal %w{content/document.xml}, Zip::File.open(temp_file).entries.map(&:name)
      end
    end
  end
  
  
  
private
  
  def a_part
    StringIO.new(<<-STR)
    <document>
      <body>Works!</body>
    </document>
    STR
  end
  
  def expand_path(path)
    File.expand_path(File.join(File.dirname(__FILE__), path))
  end
  
end
