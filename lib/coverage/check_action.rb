# frozen_string_literal: true

class CheckAction
  def initialize(coverage_path:, minimum_coverage:, github_token:, sha:)
    @coverage_path = coverage_path
    @minimum_coverage = minimum_coverage
    @github_token = github_token
    @sha = sha
  end

  def call
    coverage_results = CoverageResults.new(
      coverage_path: @coverage_path,
      minimum_coverage: @minimum_coverage
    )

    # Testing status post
    request = Request.new(access_token: @github_token)
      .post(uri: endpoint, body: body)

    # Debug
    puts request.body
    puts request.value
    puts request.inspect

    CoverageReporter.new(coverage_results: coverage_results).call
  end

  def endpoint
    owner = "joshmfrankel"
    repo = "simplecov-check-action"

    "https://api.github.com/repos/#{owner}/#{repo}/check-runs"
  end

  def body
    {
      name: "Coverage",
      head_sha: @sha,
      status: "in_progress",
      started_at: Time.now.iso8601
    }
  end
end
