# frozen_string_literal: true

# Orchestrates the translation from SimpleCov to Github Check Run API
class CheckAction
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
    # Create Check Run
    formatted_start_check = Formatters::StartCheckRun.new(repo: @repo, sha: @sha)
    request_object = Utils::Request.new(access_token: @github_token, debug: @debug)
    request = request_object.post(uri: formatted_start_check.as_uri, body: formatted_start_check.as_payload)

    check_id = JSON.parse(request.body)["id"]

    # Build End Payload Adapater
    coverage_results = Adapters::SimpleCovResult.new(
      coverage_path: @coverage_path,
      minimum_coverage: @minimum_coverage,
      minimum_coverage_type: @minimum_coverage_type
    )
    coverage_detailed_results = Adapters::SimpleCovJsonResult.new(
      coverage_json_path: @coverage_json_path,
      minimum_coverage: @minimum_coverage
    )
    payload_adapter = Adapters::GithubEndCheckPayload.new(coverage_results: coverage_results, coverage_detailed_results: coverage_detailed_results)
    formatted_end_check = Formatters::EndCheckRun.new(repo: @repo, sha: @sha, check_id: check_id, payload_adapter: payload_adapter)

    # End Check Run
    request_object.patch(uri: formatted_end_check.as_uri, body: formatted_end_check.as_payload)
  end
end
