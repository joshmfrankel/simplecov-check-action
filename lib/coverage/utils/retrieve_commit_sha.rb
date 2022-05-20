# frozen_string_literal: true

# Push events set the GITHUB_SHA to the commit at the tip of HEAD
# Pull Request events set GITHUB_SHA to the merge commit which is invalid. Therefore
# we utilize the event data provided by Github to retrieve the pull requests sha.
module Utils
  class RetrieveCommitSha
    def self.call
      json = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"]))
      pull_request_sha = json.dig("pull_request", "head", "sha")
      pull_request_sha.nil? ? ENV["GITHUB_SHA"] : pull_request_sha
    end
  end
end
