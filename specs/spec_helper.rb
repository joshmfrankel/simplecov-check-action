# frozen_string_literal: true

require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
SimpleCov.start do
  enable_coverage :branch
  # SimpleCov.minimum_coverage 90
  # SimpleCov.minimum_coverage_by_file 80
  # add_group "Low coverage" do |source_file|
  #   source_file.covered_percent < 90
  # end
end

require "net/http"
require "webmock/rspec"
require "json"
require "pry"
require "time"

require_relative "../lib/coverage/request"
require_relative "../lib/coverage/check_action"
require_relative "../lib/coverage/last_run_results"
