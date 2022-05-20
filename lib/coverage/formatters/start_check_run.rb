# frozen_string_literal: true

module Formatters
  class StartCheckRun
    def self.as_uri
      "#{Configuration.github_api_url}/#{Configuration.github_repo}/check-runs"
    end

    def self.as_payload
      {
        name: Configuration.check_job_name,
        head_sha: Configuration.github_sha,
        status: "in_progress",
        started_at: Time.now.iso8601
      }
    end
  end
end
