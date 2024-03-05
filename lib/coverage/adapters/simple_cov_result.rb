# frozen_string_literal: true

# Value object to wrap SimpleCov .last_run.json

require_relative "./group_result"

module Adapters
  class SimpleCovResult
    attr_reader :minimum_coverage

    def initialize(coverage_path:, minimum_coverage:, coverage_group: )
      @results = JSON.parse(File.read(coverage_path))
      @minimum_coverage = Float(minimum_coverage)
      @coverage_group = coverage_group

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
      return result["line"] unless @coverage_group

      GroupResult.new(group: @coverage_group).covered_percentage
    end

    private

    def result
      @_result ||= @results["result"]
    end
  end
end
