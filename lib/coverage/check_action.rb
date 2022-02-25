# frozen_string_literal: true

class CheckAction
  GITHUB_API_URL = "https://api.github.com/repos"
  GITHUB_CHECK_NAME = "SimpleCov"

  def initialize(coverage_path:, coverage_json_path:, minimum_coverage:, minimum_coverage_type:, github_token:, sha:, repo:, debug: false)
    @coverage_path = coverage_path
    @coverage_json_path = coverage_json_path
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

    coverage_detailed_results = SimpleCovJsonResults.new(
      coverage_json_path: @coverage_json_path,
      minimum_coverage: @minimum_coverage
    )

    # Create Check Run
    request_object = Request.new(access_token: @github_token, debug: @debug)
    request = request_object.post(uri: endpoint(repo: @repo), body: body)

    check_run_id = JSON.parse(request.body)["id"]

    # End Check Run
    request_object.patch(uri: "#{endpoint(repo: @repo)}/#{check_run_id}", body: ending_payload(coverage_results: coverage_results, coverage_detailed_results: coverage_detailed_results))
  end

  private

  def endpoint(repo:)
    "#{GITHUB_API_URL}/#{repo}/check-runs"
  end

  def body
    {
      name: GITHUB_CHECK_NAME,
      head_sha: @sha,
      status: "in_progress",
      started_at: Time.now.iso8601
    }
  end

  # This should become a common interface for results
  def conclusion(coverage_results:, coverage_detailed_results:)
    if coverage_detailed_results.enabled?
      coverage_detailed_results.passed? ? "success" : "failure"
    else
      coverage_results.passed? ? "success" : "failure"
    end
  end

  def build_detailed_markdown_results(coverage_detailed_results:)
    text_results = <<~TEXT
      ## Failed because the following files were below the minimum coverage
      | % | File |
      | ---- | -------- |
    TEXT

    coverage_detailed_results.each do |result|
      text_results += "| #{result["covered_percent"].round(2)} | #{result["filename"].split("/").last(3).join("/")} |\n"
    end
    text_results
  end

  def build_output_text(coverage_detailed_results:)
    if coverage_detailed_results.enabled? && !coverage_detailed_results.passed?
      build_detailed_markdown_results(coverage_detailed_results: coverage_detailed_results)
    else
      "Nothing to show"
    end
  end

  def build_output_title(coverage_results:, coverage_detailed_results:)
    if coverage_detailed_results.enabled? && !coverage_detailed_results.passed?
      "#{coverage_detailed_results.total_files_failing_coverage} file(s) below minimum #{@minimum_coverage}% coverage"
    else
      "#{coverage_results.covered_percent}% covered (minimum #{@minimum_coverage}%)"
    end
  end

  def ending_payload(coverage_results:, coverage_detailed_results:)
    conclusion = conclusion(coverage_results: coverage_results, coverage_detailed_results: coverage_detailed_results)

    summary = <<~SUMMARY
      * #{coverage_results.covered_percent}% covered
      * #{@minimum_coverage}% minimum (by #{@minimum_coverage_type})
    SUMMARY

    {
      name: GITHUB_CHECK_NAME,
      head_sha: @sha,
      status: "completed",
      completed_at: Time.now.iso8601,
      conclusion: conclusion,
      output: {
        title: build_output_title(coverage_results: coverage_results, coverage_detailed_results: coverage_detailed_results),
        summary: summary,
        text: build_output_text(coverage_detailed_results: coverage_detailed_results),
        annotations: []
      }
    }
  end
end
