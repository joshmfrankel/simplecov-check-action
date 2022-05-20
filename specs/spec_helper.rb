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

require_relative "../lib/coverage/check_action"
require_relative "../lib/coverage/configuration"
require_relative "../lib/coverage/utils/request"
require_relative "../lib/coverage/utils/retrieve_commit_sha"
require_relative "../lib/coverage/adapters/github_end_check_payload"
require_relative "../lib/coverage/adapters/simple_cov_result"
require_relative "../lib/coverage/adapters/simple_cov_json_result"
require_relative "../lib/coverage/formatters/start_check_run"
require_relative "../lib/coverage/formatters/end_check_run"
