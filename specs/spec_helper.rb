# frozen_string_literal: true
require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
SimpleCov.start

require "webmock/rspec"
require "json"
require "pry"
Dir["./lib/coverage/**/*.rb"].each do |file|
  require file
end
