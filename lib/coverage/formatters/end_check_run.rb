# frozen_string_literal: true

module Formatters
  class EndCheckRun
    def initialize(check_id:, payload_adapter:)
      @check_id = check_id
      @payload_adapter = payload_adapter
    end

    def as_uri
      "#{Configuration.github_api_url}/repos/#{Configuration.github_repo}/check-runs/#{@check_id}"
    end

    def as_payload
      {
        name: Configuration.check_job_name,
        head_sha: Configuration.github_sha,
        status: "completed",
        completed_at: Time.now.iso8601,
        conclusion: @payload_adapter.conclusion,
        output: {
          title: @payload_adapter.title,
          summary: @payload_adapter.summary,
          text: @payload_adapter.text,
          annotations: []
        }
      }
    end
  end
end
