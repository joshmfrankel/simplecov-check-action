# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/request"
require_relative "./coverage/check_action"
require_relative "./coverage/last_run_results"

json = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"]))
pull_request_sha = json.dig("pull_request", "head", "sha")

# Push events set the GITHUB_SHA to the commit at the tip of HEAD
# Pull Request events set GITHUB_SHA to the merge commit which is invalid. Therefore
# we utilize the event data provided by Github to retrieve the pull requests sha.
sha = pull_request_sha.nil? ? ENV["GITHUB_SHA"] : pull_request_sha

if ENV["INPUT_DEBUG"]
  puts <<~SHA_DEBUG
    === START SHA DEBUG ===
    #{json}
    =======================
    PR Sha: #{pull_request_sha}
    =======================
    ENV[GITHUB_SHA]: #{ENV["GITHUB_SHA"]}
    =======================
    Selected Sha: #{sha}
    === END SHA DEBUG ===
  SHA_DEBUG
end

CheckAction.new(
  # User-defined inputs
  coverage_path: ENV["INPUT_COVERAGE_PATH"],
  minimum_coverage: ENV["INPUT_MINIMUM_COVERAGE"],
  minimum_coverage_type: ENV["INPUT_MINIMUM_COVERAGE_TYPE"],
  github_token: ENV["INPUT_GITHUB_TOKEN"],
  debug: ENV["INPUT_DEBUG"],

  # Github defined EnvVars
  sha: sha,
  repo: ENV["GITHUB_REPOSITORY"]
).call
