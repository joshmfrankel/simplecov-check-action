# frozen_string_literal: true

# SimpleCovJsonResults is a Value object for interacting with SimpleCov-json results
#
# Note: This class depends heavily on client using the `simplecov-json` gem.
#       As such, there is a check to ensure we don't process it unless the
#       coverage file is detected.
module Adapters
  class SimpleCovJsonResult
    attr_reader :failing_coverage, :minimum_coverage

    def initialize(coverage_json_path:, minimum_coverage:)
      @coverage_json_path = coverage_json_path
      @minimum_coverage = Float(minimum_coverage)
      @failing_coverage = set_failing_coverage if enabled?

      if Configuration.debug_mode? && !File.readable?(@coverage_json_path)
        $stdout.puts <<~JSON
          #{@coverage_json_path} was not a valid Simplecov-json output file.

          Make sure that you have the gem in your Gemfile and have configured
          your SimpleCov.formatters correctly in your test suite.
        JSON
      end
    end

    def enabled?
      @_enabled ||= File.readable?(@coverage_json_path)
    end

    def passed?
      @failing_coverage.empty?
    end

    def each
      @failing_coverage.sort_by do |coverage|
        coverage["covered_percent"]
      end.each do |result|
        yield(result)
      end
    end

    def total_files_failing_coverage
      @failing_coverage.size
    end

    private

    def set_failing_coverage
      json = JSON.parse(File.read(@coverage_json_path))
      json["files"].select do |file|
        file["covered_percent"] < @minimum_coverage
      end
    end
  end
end
