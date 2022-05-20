# frozen_string_literal: true

# Provides simple interface for all configuration and environmental settings
class Configuration
  def self.coverage_path
    ENV["INPUT_COVERAGE_PATH"]
  end

  def self.coverage_json_path
    ENV["INPUT_COVERAGE_JSON_PATH"]
  end

  def self.minimum_suite_coverage
    ENV["INPUT_MINIMUM_SUITE_COVERAGE"]
  end

  # Requires simplecov-json results
  def self.minimum_file_coverage
    ENV["INPUT_MINIMUM_FILE_COVERAGE"]
  end

  def self.github_token
    ENV["INPUT_GITHUB_TOKEN"]
  end

  def self.github_repo
    ENV["GITHUB_REPOSITORY"]
  end

  def self.github_sha
    Utils::RetrieveCommitSha.call
  end

  def self.debug_mode?
    ENV["INPUT_DEBUG_MODE"] == "true"
  end

  def self.check_job_name
    ENV["INPUT_CHECK_JOB_NAME"]
  end

  def self.github_api_url
    "https://api.github.com/repos"
  end
end
