# frozen_string_literal: true

class CheckAction
  def initialize(coverage_path:, minimum_coverage:, minimum_coverage_type:, github_token:, sha:, repo:, debug: false)
    @coverage_path = coverage_path
    @minimum_coverage = minimum_coverage
    @minimum_coverage_type = minimum_coverage_type
    @github_token = github_token
    @sha = sha
    @repo = repo
    @debug = debug
  end

  def call
    coverage_results = LastRunResults.new(
      coverage_path: @coverage_path,
      minimum_coverage: @minimum_coverage,
      minimum_coverage_type: @minimum_coverage_type
    )

    # Create Check Run
    request_object = Request.new(access_token: @github_token, debug: @debug)
    request = request_object.post(uri: endpoint(repo: @repo), body: body)

    check_run_id = JSON.parse(request.body)["id"]

    # End Check Run
    request_object.patch(uri: "#{endpoint(repo: @repo)}/#{check_run_id}", body: ending_payload(coverage_results: coverage_results))
  end

  def endpoint(repo:)
    "https://api.github.com/repos/#{repo}/check-runs"
  end

  def body
    {
      name: "SimpleCov",
      head_sha: @sha,
      status: "in_progress",
      started_at: Time.now.iso8601
    }
  end

  def ending_payload(coverage_results:)
    conclusion = coverage_results.passed? ? "success" : "failure"
    summary = <<~SUMMARY
      * #{coverage_results.covered_percent}% covered
      * #{@minimum_coverage}% minimum (by #{@minimum_coverage_type})
    SUMMARY

    # # TODO: Loop results
    text = <<~TEXT
      | File | Coverage |
      | ---- | -------- |
    TEXT
    {
      name: "SimpleCov",
      head_sha: @sha,
      status: "completed",
      completed_at: Time.now.iso8601,
      conclusion: conclusion,
      output: {
        title: "#{coverage_results.covered_percent}% covered (minimum #{@minimum_coverage}%)",
        summary: summary,
        text: "The text",
        annotations: []
      }
    }
  end
end
