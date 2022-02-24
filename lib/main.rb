# frozen_string_literal: true

require "net/http"
require "json"
require "time"
require_relative "./coverage/request"
require_relative "./coverage/check_action"
require_relative "./coverage/last_run_results"

json = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"]))
pull_request_sha = json.dig("pull_request", "head", "sha")
puts "OUTPUT"
puts ENV["GITHUB_SHA"]
puts "===================="
puts json
puts "===================="
puts json["pull_request"]
puts "===================="
puts json["pull_request"]["head"]
puts "===================="
puts json["pull_request"]["head"]["sha"]
puts "===================="
puts pull_request_sha
puts "===================="
puts "END"

sha = pull_request_sha.nil? ? ENV["GITHUB_SHA"] : pull_request_sha

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

# TODO
# * Toggle whether it should fail based on minimum
# * Allow custom format?
