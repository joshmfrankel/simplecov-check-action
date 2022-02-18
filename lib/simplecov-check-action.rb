# frozen_string_literal: true

require "json"
Dir["./simplecov-check-action/*.rb"].each { |file| require file }

parsed_coverage = JSON.parse(File.read(ENV["INPUT_COVERAGE_PATH"]))
metrics = parsed_coverage["metrics"]

if metrics["covered_percent"] >= Float(ENV["INPUT_MINIMUM_COVERAGE"])
  $stdout.puts("PASSED - Coverage Analysis")
  $stdout.puts("=================================================")
  $stdout.puts("Covered: #{metrics["covered_percent"].round(2)}%")
  $stdout.puts("Minimum: #{ENV["INPUT_MINIMUM_COVERAGE"]}%")
  $stdout.puts("Lines: #{metrics["covered_lines"]}%")
  $stdout.puts("Total: #{metrics["total_lines"]}%")
  exit(0)
else
  $stdout.puts("FAILED - Coverage Analysis")
  $stdout.puts("=================================================")
  $stdout.puts("Covered: #{metrics["covered_percent"].round(2)}%")
  $stdout.puts("Minimum: #{ENV["INPUT_MINIMUM_COVERAGE"]}%")
  $stdout.puts("Lines: #{metrics["covered_lines"]}%")
  $stdout.puts("Total: #{metrics["total_lines"]}%")
  exit(1)
end
