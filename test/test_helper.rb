require "rubygems"

require "simplecov"
SimpleCov.start do
  add_filter "test/"
end

require "rails"
require "rails/test_help"
require "turn"
require "pry"
require "rr"
require "shoulda/context"

require "open_xml_package"
