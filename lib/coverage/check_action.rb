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

    # Create Check Run
    request_object = Request.new(access_token: @github_token)
    request = request_object.post(uri: endpoint, body: body)

    check_run_id = JSON.parse(request.body)["id"]

    puts check_run_id
    puts JSON.parse(request.body)

    if request.code.to_i >= 300
      raise "#{request.message}: #{request.body}"
    end

    puts "Ending run"

    # End Check Run
    puts "#{endpoint}/#{check_run_id}"
    response = request_object.patch(uri: "#{endpoint}/#{check_run_id}", body: ending_payload)

    puts response.code
    if response.code.to_i >= 300
      puts JSON.parse(response.body)
      raise "#{response.message}: #{response.body}"
    end
  end

  def endpoint
    owner = "joshmfrankel"
    repo = "simplecov-check-action"

    "https://api.github.com/repos/#{owner}/#{repo}/check-runs"
  end

  def body
    {
      name: "SimpleCov Results",
      head_sha: @sha,
      status: "in_progress",
      started_at: Time.now.iso8601
    }
  end

  def ending_payload
    {
      name: "SimpleCov Results",
      head_sha: @sha,
      status: "completed",
      completed_at: Time.now.iso8601,
      conclusion: "success",
      output: {
        title: "SimpleCov Results",
        summary: "The summary",
        text: "The text",
        annotations: []
      }
    }
  end
end
