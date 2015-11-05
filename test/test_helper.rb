require "rubygems"

require "simplecov"
SimpleCov.start do
  add_filter "test/"
end

require "rails"
require "rails/test_help"
require "pry"
require "rr"
require "shoulda/context"
require "minitest/reporters/turn_reporter"
MiniTest::Reporters.use! Minitest::Reporters::TurnReporter.new

require "open_xml_package"
