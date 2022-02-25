# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/request"
require_relative "./coverage/retrieve_commit_sha"
require_relative "./coverage/check_action"
require_relative "./coverage/last_run_results"
require_relative "./coverage/simple_cov_json_results"

CheckAction.new(
  # User-defined inputs
  coverage_path: ENV["INPUT_COVERAGE_PATH"],
  coverage_json_path: ENV["INPUT_COVERAGE_JSON_PATH"],
  minimum_coverage: ENV["INPUT_MINIMUM_COVERAGE"],
  minimum_coverage_type: ENV["INPUT_MINIMUM_COVERAGE_TYPE"],
  github_token: ENV["INPUT_GITHUB_TOKEN"],
  debug: ENV["INPUT_DEBUG"],

  # Github defined EnvVars
  sha: RetrieveCommitSha.call,
  repo: ENV["GITHUB_REPOSITORY"]
).call
