# frozen_string_literal: true

module Formatters
  class StartCheckRun
    GITHUB_CHECK_NAME = "SimpleCov"
    GITHUB_API_URL = "https://api.github.com/repos"

    def initialize(repo:, sha:)
      @repo = repo
      @sha = sha
    end

    def as_uri
      "#{GITHUB_API_URL}/#{@repo}/check-runs"
    end

    def as_payload
      {
        name: GITHUB_CHECK_NAME,
        head_sha: @sha,
        status: "in_progress",
        started_at: Time.now.iso8601
      }
    end
  end
end
