# frozen_string_literal: true

# Value object to wrap SimpleCov .last_run.json
module Adapters
  class SimpleCovResult
    attr_reader :minimum_coverage

    def initialize(coverage_path:, minimum_coverage:)
      @results = JSON.parse(File.read(coverage_path))
      @minimum_coverage = Float(minimum_coverage)

      raise "#{coverage_path} does not contain `line` key" unless !result.nil? && result.key?("line")
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
      result["line"]
    end

    private

    def result
      @_result ||= @results["result"]
    end
  end
end
