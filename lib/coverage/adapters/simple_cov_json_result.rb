# frozen_string_literal: true

# SimpleCovJsonResults is a Value object for interacting with SimpleCov-json results
#
# Note: This class depends heavily on client using the `simplecov-json` gem.
#       As such, there is a check to ensure we don't process it unless the
#       coverage file is detected.
module Adapters
  class SimpleCovJsonResult
    attr_reader :failing_coverage

    def initialize(coverage_json_path:, minimum_coverage:)
      @coverage_json_path = coverage_json_path
      @minimum_coverage = Float(minimum_coverage)
      @failing_coverage = set_failing_coverage if enabled?
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
