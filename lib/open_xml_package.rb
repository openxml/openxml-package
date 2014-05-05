require "open_xml_package/version"
require "zip"


class OpenXmlPackage
  attr_reader :parts

  def initialize
    @parts = {}
  end

  def add_part(path, part)
    parts[path] = part
  end

  def write_to(path)
    Zip::OutputStream.open(path) do |io|
      parts.each do |path, part|
        io.put_next_entry path
        io.write part.read
      end
    end
  end

end
