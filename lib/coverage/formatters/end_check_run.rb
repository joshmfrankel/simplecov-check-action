# frozen_string_literal: true

module Formatters
  class EndCheckRun
    def initialize(check_id:, payload_adapter:)
      @check_id = check_id
      @payload_adapter = payload_adapter
    end

    def as_uri
      "#{Configuration.github_api_url}/#{Configuration.github_repo}/check-runs/#{@check_id}"
    end

    # GitHub Check Run API limits the output text to 65535 characters.
    MAX_OUTPUT_TEXT_LENGTH = 65_535

    def as_payload
      text = @payload_adapter.text
      summary = @payload_adapter.summary
      max_text = MAX_OUTPUT_TEXT_LENGTH - summary.to_s.length
      if text.length > max_text
        truncation_msg = "\n\n... output truncated due to GitHub API character limit ..."
        text = text[0, max_text - truncation_msg.length] + truncation_msg
      end

      {
        name: Configuration.check_job_name,
        head_sha: Configuration.github_sha,
        status: "completed",
        completed_at: Time.now.iso8601,
        conclusion: @payload_adapter.conclusion,
        output: {
          title: @payload_adapter.title,
          summary: summary,
          text: text,
          annotations: []
        }
      }
    end
  end
end
