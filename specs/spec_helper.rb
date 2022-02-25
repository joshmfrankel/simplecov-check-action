# frozen_string_literal: true

require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
SimpleCov.start do
  enable_coverage :branch
end

require "net/http"
require "webmock/rspec"
require "json"
require "pry"
require "time"
require "climate_control"

require_relative "../lib/coverage/request"
require_relative "../lib/coverage/check_action"
require_relative "../lib/coverage/last_run_results"
require_relative "../lib/coverage/retrieve_commit_sha"
require_relative "../lib/coverage/simple_cov_json_results"
