require "open_xml_package/part"
require "open_xml_package/version"
require "zip"


class OpenXmlPackage
  attr_reader :parts

  def initialize
    @parts = []
  end

  def add_part(path_or_part, content=nil)
    path = path_or_part
    path = path_or_part.path if path_or_part.respond_to?(:path)
    content = path_or_part.read if path_or_part.respond_to?(:read)
    
    @parts << Part.new(path, content)
  end

  def write_to(path)
    File.open(path, "w") do |file|
      file.write to_stream.string
    end
  end
  
  def to_stream
    Zip::OutputStream.write_buffer do |io|
      parts.each do |part|
        io.put_next_entry part.path
        io.write part.content
      end
    end
  end

end
