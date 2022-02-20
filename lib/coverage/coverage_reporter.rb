# frozen_string_literal: true

class CoverageReporter
  def initialize(coverage_results:)
    @coverage_results = coverage_results
  end

  def call
    $stdout.puts("=================================================")
    if @coverage_results.passed?
      $stdout.puts("PASSED - Coverage Analysis")
      $stdout.puts("=================================================")
      $stdout.puts("Covered: #{@coverage_results.covered_percent}%")
      $stdout.puts("Minimum: #{@coverage_results.minimum_coverage}%")
      $stdout.puts("Lines: #{@coverage_results.covered_lines}")
      $stdout.puts("Total: #{@coverage_results.total_lines}")
      exit(0)
    else
      $stdout.puts("FAILED - Coverage Analysis")
      $stdout.puts("=================================================")
      $stdout.puts("Covered: #{@coverage_results.covered_percent}%")
      $stdout.puts("Minimum: #{@coverage_results.minimum_coverage}%")
      $stdout.puts("Lines: #{@coverage_results.covered_lines}")
      $stdout.puts("Total: #{@coverage_results.total_lines}")
      exit(1)
    end
  end
end
