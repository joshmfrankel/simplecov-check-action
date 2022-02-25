# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/request"
require_relative "./coverage/retrieve_commit_sha"
require_relative "./coverage/check_action"
require_relative "./coverage/adapters/simple_cov_result"
require_relative "./coverage/adapters/simple_cov_json_result"
require_relative "./coverage/adapters/github_end_check_payload"
require_relative "./coverage/formatters/start_check_run"
require_relative "./coverage/formatters/end_check_run"

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
