# frozen_string_literal: true

class CoverageReporter
  def initialize(coverage_results:)
    @coverage_results = coverage_results
  end

  def call
    $stdout.puts("=================================================")
    if @coverage_results.passed?
      $stdout.puts <<~OUTPUT
        PASSED - Coverage Analysis
        =================================================
        Covered: #{@coverage_results.covered_percent}%
        Minimum: #{@coverage_results.minimum_coverage}%
        Lines: #{@coverage_results.covered_lines}
        Total: #{@coverage_results.total_lines}
      OUTPUT
      exit(0)
    else
      $stdout.puts <<~OUTPUT
        FAILED - Coverage Analysis
        =================================================
        Covered: #{@coverage_results.covered_percent}%
        Minimum: #{@coverage_results.minimum_coverage}%
        Lines: #{@coverage_results.covered_lines}
        Total: #{@coverage_results.total_lines}
      OUTPUT
      exit(1)
    end
  end
end
