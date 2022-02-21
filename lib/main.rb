# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/request"
require_relative "./coverage/check_action"
require_relative "./coverage/coverage_results"

CheckAction.new(
  # User-defined inputs
  coverage_path: ENV["INPUT_COVERAGE_PATH"],
  minimum_coverage: ENV["INPUT_MINIMUM_COVERAGE"],
  github_token: ENV["INPUT_GITHUB_TOKEN"],

  # Github defined EnvVars
  sha: ENV["GITHUB_SHA"]
).call
