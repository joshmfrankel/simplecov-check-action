# frozen_string_literal: true

# Value object to wrap SimpleCov .last_run.json
module Adapters
  class SimpleCovResult
    attr_reader :minimum_coverage, :minimum_coverage_type

    def initialize(coverage_path:, minimum_coverage:, minimum_coverage_type:)
      @results = JSON.parse(File.read(coverage_path))
      @minimum_coverage = Float(minimum_coverage)
      @minimum_coverage_type = minimum_coverage_type

      raise "#{coverage_path} does not contain `#{minimum_coverage_type}` key" unless !result.nil? && result.key?(@minimum_coverage_type)
    end

    # Determine pass/fail response for SimpleCov
    #
    # @return [Boolean]
    def passed?
      covered_percent >= @minimum_coverage
    end

    # Display covered percentage based on the type of requested coverage type.
    #
    # @return [Float]
    def covered_percent
      @minimum_coverage_type == "line" ? line_coverage : branch_coverage
    end

    private

    def result
      @_result ||= @results["result"]
    end

    def line_coverage
      result["line"]
    end

    def branch_coverage
      result["branch"]
    end
  end
end
