# frozen_string_literal: true

require "net/http"
require "json"
require_relative "./request"
require_relative "./coverage/check_action"
require_relative "./coverage/coverage_results"
require_relative "./coverage/coverage_reporter"

CheckAction.new(
  coverage_path: ENV["INPUT_COVERAGE_PATH"],
  minimum_coverage: ENV["INPUT_MINIMUM_COVERAGE"],
  github_token: ENV["INPUT_GITHUB_TOKEN"],
  sha: ENV["GITHUB_SHA"]
).call
