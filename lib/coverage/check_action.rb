# frozen_string_literal: true

class CheckAction
  def initialize(coverage_path:, minimum_coverage:, github_token:)
    @coverage_path = coverage_path
    @minimum_coverage = minimum_coverage
    @github_token = github_token
  end

  def call
    coverage_results = CoverageResults.new(
      coverage_path: @coverage_path,
      minimum_coverage: @minimum_coverage
    )

    # Testing status post
    client = Octokit::Client.new(access_token: @github_token)
    puts client.api_endpoint
    puts client.user

    CoverageReporter.new(coverage_results: coverage_results).call
  end
end
