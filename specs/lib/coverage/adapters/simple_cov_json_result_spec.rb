# frozen_string_literal: true

require './specs/spec_helper'
require 'tempfile'

describe Adapters::SimpleCovJsonResult do
  def build_result(coverage_json_path, minimum_coverage: 70)
    described_class.new(
      coverage_json_path: coverage_json_path,
      minimum_coverage: minimum_coverage
    )
  end

  def with_coverage_file(content)
    Tempfile.create(['coverage', '.json']) do |file|
      file.write(content)
      file.flush
      yield(file.path)
    end
  end

  def native_coverage(schema_version: '1.0')
    {
      'meta' => { 'schema_version' => schema_version },
      'coverage' => {
        'lib/example.rb' => { 'lines_covered_percent' => 75.0 }
      }
    }
  end

  describe 'legacy simplecov-json results' do
    subject(:result) do
      described_class.new(
        coverage_json_path: 'specs/fakes/optional_fake_simplecov_json.json',
        minimum_coverage: 99
      )
    end

    it 'remains enabled and reports files below the threshold' do
      expect(result).to be_enabled
      expect(result.total_files_failing_coverage).to eq(4)
    end
  end

  describe 'native SimpleCov 1.x results' do
    subject(:result) do
      described_class.new(
        coverage_json_path: 'specs/fakes/fake_simplecov_1_coverage.json',
        minimum_coverage: 70
      )
    end

    it 'normalizes line coverage and applies the threshold' do
      failing_files = []
      result.each { |file| failing_files << file }

      expect(result).to be_enabled
      expect(result).not_to be_passed
      expect(failing_files).to eq([
                                    {
                                      'filename' => 'lib/coverage/check_action.rb',
                                      'covered_percent' => 50.0
                                    }
                                  ])
    end
  end

  describe 'an unreadable coverage file' do
    subject(:result) do
      described_class.new(
        coverage_json_path: 'specs/fakes/does_not_exist.json',
        minimum_coverage: 70
      )
    end

    it 'disables per-file coverage checks' do
      expect(result).not_to be_enabled
      expect(result).to be_passed
    end
  end

  describe 'an unsupported coverage format' do
    it 'raises a descriptive error' do
      expect do
        described_class.new(
          coverage_json_path: 'specs/fakes/fake_bad_format.json',
          minimum_coverage: 70
        )
      end.to raise_error(ArgumentError, /is not a supported SimpleCov coverage JSON file/)
    end
  end

  describe 'malformed JSON' do
    it 'raises a descriptive error' do
      with_coverage_file('{') do |path|
        expect { build_result(path) }.to raise_error(ArgumentError, /invalid JSON/)
      end
    end
  end

  describe 'native schema versions' do
    it 'accepts additive 1.x schema versions' do
      with_coverage_file(native_coverage(schema_version: '1.1').to_json) do |path|
        result = build_result(path)

        expect(result).to be_enabled
        expect(result).to be_passed
      end
    end

    it 'rejects unsupported major schema versions' do
      with_coverage_file(native_coverage(schema_version: '2.0').to_json) do |path|
        expect do
          build_result(path)
        end.to raise_error(ArgumentError, /unsupported native SimpleCov schema version/)
      end
    end
  end

  describe 'native coverage without a line percentage' do
    it 'raises a descriptive error' do
      coverage = native_coverage
      coverage['coverage']['lib/example.rb'].delete('lines_covered_percent')

      with_coverage_file(coverage.to_json) do |path|
        expect do
          build_result(path)
        end.to raise_error(ArgumentError, /numeric line coverage percentage/)
      end
    end
  end
end
