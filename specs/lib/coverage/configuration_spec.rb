# frozen_string_literal: true

require './specs/spec_helper'

describe Configuration do
  describe 'matches defaults from action.yml' do
    it 'uses action.yml default for check_job_name' do
      ClimateControl.modify(INPUT_CHECK_JOB_NAME: nil) do
        expect(described_class.check_job_name).to eq('SimpleCov')
      end
    end

    it 'uses action.yml default for minimum_suite_coverage' do
      ClimateControl.modify(INPUT_MINIMUM_SUITE_COVERAGE: nil) do
        expect(described_class.minimum_suite_coverage).to eq('90')
      end
    end

    it 'uses action.yml default for minimum_file_coverage' do
      ClimateControl.modify(INPUT_MINIMUM_FILE_COVERAGE: nil) do
        expect(described_class.minimum_file_coverage).to eq('70')
      end
    end

    it 'uses action.yml default for coverage_path' do
      ClimateControl.modify(INPUT_COVERAGE_PATH: nil) do
        expect(described_class.coverage_path).to eq('coverage/.last_run.json')
      end
    end

    it 'uses action.yml default for coverage_json_path' do
      ClimateControl.modify(INPUT_COVERAGE_JSON_PATH: nil) do
        expect(described_class.coverage_json_path).to eq('coverage/coverage.json')
      end
    end

    it 'uses action.yml default for debug_mode' do
      ClimateControl.modify(INPUT_DEBUG_MODE: nil) do
        expect(described_class.debug_mode?).to eq(false)
      end
    end

    it 'uses action.yml default for on_fail_status' do
      ClimateControl.modify(INPUT_ON_FAIL_STATUS: nil) do
        expect(described_class.on_fail_status).to eq('failure')
      end
    end

    it 'uses action.yml default for github_repo_api_url' do
      ClimateControl.modify(INPUT_GITHUB_REPO_API_URL: nil) do
        expect(described_class.github_repo_api_url).to eq('https://api.github.com/repos')
      end
    end
  end
end
