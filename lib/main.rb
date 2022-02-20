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

# Action.new(env: ENV)
# binding.pry
# coverage_results = CoverageResults.new(
#   coverage_path: ENV["INPUT_COVERAGE_PATH"],
#   minimum_coverage: ENV["INPUT_MINIMUM_COVERAGE"]
# )

# url = "https://api.github.com/repos/#{@github_data[:owner]}/#{@github_data[:repo]}/check-runs"


# # NetClient.new(url: url, payload: , headers:)


# CoverageReporter.new(coverage_results: coverage_results).call


# github_token = ENV["INPUT_GITHUB_TOKEN"]

# headers = {
#   "Content-Type": "application/json",
#   "Accept": "application/vnd.github.antiope-preview+json",
#   "Authorization": "Bearer #{github_token}",
#   "User-Agent": "Coverage Action"
# }

# http = Net::HTTP.new("api.github.com", 443)
# http.use_ssl = true
# response = yield(http)
# raise "#{response.message}: #{response.body}" if response.code.to_i >= 300

# request_http = JSON.parse(response.body)

# # Start check
# id = @client.post(
#       endpoint_url,
#       create_check_payload
#     )['id']

# request_http do |http|
#   http.post(url, body.to_json, headers)
# end



