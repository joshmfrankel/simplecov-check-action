# frozen_string_literal: true

module Adapters
  class GithubEndCheckPayload
    def initialize(coverage_results:, coverage_detailed_results:)
      @coverage_results = coverage_results
      @coverage_detailed_results = coverage_detailed_results
    end

    def conclusion
      if @coverage_detailed_results.enabled?
        @coverage_detailed_results.passed? ? "success" : "failure"
      else
        @coverage_results.passed? ? "success" : "failure"
      end
    end

    def title
      if @coverage_detailed_results.enabled? && !@coverage_detailed_results.passed?
        "#{@coverage_detailed_results.total_files_failing_coverage} file(s) below minimum #{@coverage_results.minimum_coverage}% coverage"
      else
        "#{@coverage_results.covered_percent}% covered (minimum #{@coverage_results.minimum_coverage}%)"
      end
    end

    def summary
      <<~SUMMARY
        * #{@coverage_results.covered_percent}% covered
        * #{@coverage_results.minimum_coverage}% minimum (by #{@coverage_results.minimum_coverage_type})
      SUMMARY
    end

    def text
      if @coverage_detailed_results.enabled? && !@coverage_detailed_results.passed?
        build_detailed_markdown_results
      else
        "Nothing to show"
      end
    end

    private

    def build_detailed_markdown_results
      text_results = <<~TEXT
        ### Failed because the following files were below the minimum coverage
        | % | File |
        | ---- | -------- |
      TEXT

      @coverage_detailed_results.each do |result|
        text_results += "| #{result["covered_percent"].round(2)} | #{result["filename"].split("/").last(3).join("/")} |\n"
      end
      text_results
    end
  end
end
