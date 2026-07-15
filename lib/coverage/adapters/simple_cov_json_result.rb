# frozen_string_literal: true

module Adapters
  # Value object for interacting with native SimpleCov and simplecov-json results.
  class SimpleCovJsonResult
    SUPPORTED_NATIVE_SCHEMA_MAJOR = "1"

    attr_reader :failing_coverage, :minimum_coverage

    def initialize(coverage_json_path:, minimum_coverage:)
      @coverage_json_path = coverage_json_path
      @minimum_coverage = Float(minimum_coverage)
      @coverage_files = load_coverage_files if File.readable?(@coverage_json_path)
      @failing_coverage = set_failing_coverage
      log_unreadable_coverage_file if Configuration.debug_mode? && !File.readable?(@coverage_json_path)
    end

    def enabled?
      !@coverage_files.nil?
    end

    def passed?
      @failing_coverage.empty?
    end

    def each(&block)
      @failing_coverage.sort_by { |coverage| coverage["covered_percent"] }.each(&block)
    end

    def total_files_failing_coverage
      @failing_coverage.size
    end

    private

    def set_failing_coverage
      return [] unless enabled?

      @coverage_files.select do |file|
        file["covered_percent"] < @minimum_coverage
      end
    end

    def load_coverage_files
      json = JSON.parse(File.read(@coverage_json_path))
      validate_coverage_files(coverage_files_from(json))
    rescue JSON::ParserError => e
      raise_invalid_format("invalid JSON: #{e.message}")
    end

    def coverage_files_from(json)
      raise_invalid_format("expected a top-level JSON object") unless json.is_a?(Hash)
      return json["files"] if json["files"].is_a?(Array)
      return normalize_native_coverage(json) if native_coverage?(json)

      raise_invalid_format(
        "expected a top-level `files` array or native SimpleCov `meta` and `coverage` objects"
      )
    end

    def native_coverage?(json)
      json["meta"].is_a?(Hash) && json["coverage"].is_a?(Hash)
    end

    def normalize_native_coverage(json)
      ensure_supported_native_schema!(json)

      json["coverage"].map do |filename, coverage|
        covered_percent = coverage["lines_covered_percent"] if coverage.is_a?(Hash)
        {
          "filename" => filename,
          "covered_percent" => covered_percent
        }
      end
    end

    def ensure_supported_native_schema!(json)
      schema_version = json.dig("meta", "schema_version")
      schema_major = schema_version.to_s.split(".").first
      return if schema_major == SUPPORTED_NATIVE_SCHEMA_MAJOR

      raise_invalid_format("unsupported native SimpleCov schema version #{schema_version.inspect}; expected 1.x")
    end

    def validate_coverage_files(files)
      valid = files.all? do |file|
        file.is_a?(Hash) &&
          file["filename"].is_a?(String) &&
          file["covered_percent"].is_a?(Numeric)
      end

      raise_invalid_format("each file must contain a filename and numeric line coverage percentage") unless valid

      files
    end

    def raise_invalid_format(reason)
      message = "#{@coverage_json_path} is not a supported SimpleCov coverage JSON file: #{reason}"
      raise ArgumentError, message
    end

    def log_unreadable_coverage_file
      $stdout.puts <<~JSON
        #{@coverage_json_path} was not a readable SimpleCov coverage JSON file.

        Make sure your test suite generated a SimpleCov 1.x coverage report,
        or configure the simplecov-json formatter when using older versions.
      JSON
    end
  end
end
