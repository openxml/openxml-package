module OpenXml
  module Properties
  end
end

require "openxml/properties/base_property"
require "openxml/properties/complex_property"
require "openxml/properties/value_property"

require "openxml/properties/boolean_property"
require "openxml/properties/integer_property"
require "openxml/properties/positive_integer_property"
require "openxml/properties/string_property"
require "openxml/properties/on_off_property"
require "openxml/properties/toggle_property"

require "openxml/properties/container_property"
require "openxml/properties/transparent_container_property"

Dir.glob(File.join(File.dirname(__FILE__), "properties", "*.rb").to_s).each do |file|
  require file
end
