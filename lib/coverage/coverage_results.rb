# frozen_string_literal: true

# CoverageResults is a Value object for interacting with SimpleCov results
class CoverageResults
  attr_reader :minimum_coverage

  def initialize(coverage_path:, minimum_coverage:)
    @results = JSON.parse(File.read(coverage_path))
    @minimum_coverage = Float(minimum_coverage)
  end

  def metrics
    @_metrics ||= Metrics.new(results: @results["metrics"])
  end

  def passed?
    covered_percent >= @minimum_coverage
  end

  # Delegates to Metrics
  def covered_percent
    metrics.covered_percent
  end

  # Delegates to Metrics
  def covered_lines
    metrics.covered_lines
  end

  # Delegates to Metrics
  def total_lines
    metrics.total_lines
  end

  class Metrics
    def initialize(results:)
      @metric_result = results
    end

    def covered_percent
      Float(@metric_result["covered_percent"]).round(2)
    end

    def covered_lines
      @metric_result["covered_lines"]
    end

    def total_lines
      @metric_result["total_lines"]
    end
  end
end
