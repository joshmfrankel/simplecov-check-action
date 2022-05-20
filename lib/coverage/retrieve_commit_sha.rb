# frozen_string_literal: true

# Push events set the GITHUB_SHA to the commit at the tip of HEAD
# Pull Request events set GITHUB_SHA to the merge commit which is invalid. Therefore
# we utilize the event data provided by Github to retrieve the pull requests sha.
class RetrieveCommitSha
  def self.call
    json = JSON.parse(File.read(ENV["GITHUB_EVENT_PATH"]))
    pull_request_sha = json.dig("pull_request", "head", "sha")

    $stdout.puts ENV["INPUT_DEBUG"]
    $stdout.puts "-----"

    print_debug_log(json, pull_request_sha) if ENV["INPUT_DEBUG"] == true

    pull_request_sha.nil? ? ENV["GITHUB_SHA"] : pull_request_sha
  end

  private_class_method

  def self.print_debug_log(json, pull_request_sha)
    $stdout.puts <<~SHA_DEBUG
      === START SHA DEBUG ===
      RAW JSON:
      #{json}
      =======================
      PR Sha: #{pull_request_sha}
      =======================
      ENV[GITHUB_SHA]: #{ENV["GITHUB_SHA"]}
      === END SHA DEBUG ===
    SHA_DEBUG
  end
end
