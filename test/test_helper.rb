$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "openxml/package"

require "simplecov"
SimpleCov.start do
  add_filter "test/"
end

require "minitest/reporters/turn_reporter"
MiniTest::Reporters.use! Minitest::Reporters::TurnReporter.new

require "shoulda/context"
require "pry"
require "rr"
require "minitest/autorun"
