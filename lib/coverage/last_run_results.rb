# frozen_string_literal: true

class LastRunResults
  def initialize(coverage_path:, minimum_coverage:, minimum_coverage_type:)
    @results = JSON.parse(File.read(coverage_path))
    @minimum_coverage = Float(minimum_coverage)
    @minimum_coverage_type = minimum_coverage_type

    raise "#{coverage_path} does not contain `#{minimum_coverage_type}` key" unless !result.nil? && result.key?(@minimum_coverage_type)
  end

  def passed?
    covered_percent >= @minimum_coverage
  end

  def result
    @_result ||= @results["result"]
  end

  def covered_percent
    @minimum_coverage_type == "line" ? line_coverage : branch_coverage
  end

  def line_coverage
    result["line"]
  end

  def branch_coverage
    result["branch"]
  end
end
