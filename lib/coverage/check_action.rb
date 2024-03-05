# frozen_string_literal: true

# Orchestrates the translation from SimpleCov to Github Check Run API
class CheckAction
  def call
    # Create Check Run
    request_object = Utils::Request.new(access_token: Configuration.github_token, debug: Configuration.debug_mode?)
    request = request_object.post(uri: Formatters::StartCheckRun.as_uri, body: Formatters::StartCheckRun.as_payload)

    check_id = JSON.parse(request.body)["id"]

    # Build End Payload Adapater
    coverage_results = Adapters::SimpleCovResult.new(
      coverage_path: Configuration.coverage_path,
      minimum_coverage: Configuration.minimum_suite_coverage,
      coverage_group: Configuration.coverage_group
    )
    coverage_detailed_results = Adapters::SimpleCovJsonResult.new(
      coverage_json_path: Configuration.coverage_json_path,
      minimum_coverage: Configuration.minimum_file_coverage
    )
    payload_adapter = Adapters::GithubEndCheckPayload.new(
      coverage_results: coverage_results,
      coverage_detailed_results: coverage_detailed_results
    )
    formatted_end_check = Formatters::EndCheckRun.new(
      check_id: check_id,
      payload_adapter: payload_adapter
    )

    # End Check Run
    request_object.patch(uri: formatted_end_check.as_uri, body: formatted_end_check.as_payload)
  end
end
