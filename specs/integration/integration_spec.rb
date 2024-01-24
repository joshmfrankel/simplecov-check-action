# frozen_string_literal: true

require "./specs/spec_helper"

describe "Check Action integration" do
  let(:github_token) { "hzI7onpyGIGAjg==" }
  let(:check_run_id) { 1 }
  let(:sha) { "foobarbaz" }

  # Note: This must match sha key in fake
  # @see specs/fakes/fake_github_event_path_pull_request.json
  let(:pull_request_json_sha) { "3f2dc54bfec0b5295c6" }
  let(:the_time) { "2022-02-21T09:51:57-05:00" }
  let(:repo) { "robswire/immersion" }
  let(:passing_markdown_text) { "No details to show" }
  let(:on_fail_status) { "failure" }

  context "for coverage type line" do
    context "for Pushes" do
      it "raises RuntimeError when coverage file doesn't contain `line` key" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time)
        expect(mock_time).to receive(:iso8601).and_return(the_time)
        minimum_coverage = "100"

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_bad_format.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token
        ) do
          expect {
            CheckAction.new.call
          }.to raise_error(RuntimeError)
        end
      end

      it "Fails when coverage is lower than suite minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = "100"

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token,
          INPUT_ON_FAIL_STATUS: on_fail_status
        ) do
          CheckAction.new.call
        end
      end

      it "Passes when coverage is greater than or equal to suite minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = "80"

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token
        ) do
          CheckAction.new.call
        end
      end

      it "prints invalid file when coverage_json_path is invalid and debug_mode is enabled" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = "49" # 50 is lowest in fake file

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token,
          INPUT_DEBUG_MODE: "true"
        ) do
          expect {
            CheckAction.new.call
          }.to output(/specs\/fakes\/xx_not_a_file\.json was not a valid Simplecov-json output file./).to_stdout
        end
      end

      context "when SimpleCov-json coverage file is present" do
        it "Passes when all file coverages are above minimum" do
          mock_time = instance_double(Time)
          expect(Time).to receive(:now).and_return(mock_time).twice
          expect(mock_time).to receive(:iso8601).and_return(the_time).twice
          minimum_coverage = "49" # 50 is lowest in fake file

          stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
            .to_return(body: { id: check_run_id }.to_json, status: 201)

          stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n* #{minimum_coverage}.0 minimum coverage per file\n", text: passing_markdown_text, annotations: [] } })

          ClimateControl.modify(
            GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
            GITHUB_SHA: sha,
            GITHUB_REPOSITORY: repo,
            INPUT_CHECK_JOB_NAME: "SimpleCov",
            INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
            INPUT_COVERAGE_JSON_PATH: "specs/fakes/optional_fake_simplecov_json.json",
            INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
            INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
            INPUT_GITHUB_TOKEN: github_token
          ) do
            CheckAction.new.call
          end
        end

        it "Fails when coverage is lower than file minimum and prints failing files" do
          mock_time = instance_double(Time)
          expect(Time).to receive(:now).and_return(mock_time).twice
          expect(mock_time).to receive(:iso8601).and_return(the_time).twice
          minimum_suite_coverage = "49"
          minimum_file_coverage = "99"
          failing_markdown_text = <<~TEXT
            ### Failed because the following files were below the minimum coverage
            | % | File |
            | ---- | -------- |
            | 50.0 | lib/coverage/check_action.rb |
            | 88.89 | lib/coverage/retrieve_commit_sha.rb |
            | 92.0 | lib/coverage/request.rb |
            | 98.0 | lib/coverage/last_run_results.rb |
          TEXT

          stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
            .to_return(body: { id: check_run_id }.to_json, status: 201)

          stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "4 file(s) below minimum #{minimum_file_coverage}.0% coverage", summary: "* 97.77% covered\n" + "* #{minimum_suite_coverage}.0% minimum coverage for suite\n* #{minimum_file_coverage}.0 minimum coverage per file\n", text: failing_markdown_text, annotations: [] } })

          ClimateControl.modify(
            GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
            GITHUB_SHA: sha,
            GITHUB_REPOSITORY: repo,
            INPUT_CHECK_JOB_NAME: "SimpleCov",
            INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
            INPUT_COVERAGE_JSON_PATH: "specs/fakes/optional_fake_simplecov_json.json",
            INPUT_MINIMUM_SUITE_COVERAGE: minimum_suite_coverage,
            INPUT_MINIMUM_FILE_COVERAGE: minimum_file_coverage,
            INPUT_GITHUB_TOKEN: github_token,
            INPUT_ON_FAIL_STATUS: on_fail_status
          ) do
            CheckAction.new.call
          end
        end

        it "Fails when fallback suite minimum coverage fails" do
          mock_time = instance_double(Time)
          expect(Time).to receive(:now).and_return(mock_time).twice
          expect(mock_time).to receive(:iso8601).and_return(the_time).twice
          minimum_suite_coverage = "99"
          minimum_file_coverage = "0" # Basically disables failing on per file coverage

          stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
            .to_return(body: { id: check_run_id }.to_json, status: 201)

          stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "97.77% covered (minimum #{minimum_suite_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_suite_coverage}.0% minimum coverage for suite\n* #{minimum_file_coverage}.0 minimum coverage per file\n", text: passing_markdown_text, annotations: [] } })

          ClimateControl.modify(
            GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json",
            GITHUB_SHA: sha,
            GITHUB_REPOSITORY: repo,
            INPUT_CHECK_JOB_NAME: "SimpleCov",
            INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
            INPUT_COVERAGE_JSON_PATH: "specs/fakes/optional_fake_simplecov_json.json",
            INPUT_MINIMUM_SUITE_COVERAGE: minimum_suite_coverage,
            INPUT_MINIMUM_FILE_COVERAGE: minimum_file_coverage,
            INPUT_GITHUB_TOKEN: github_token,
            INPUT_ON_FAIL_STATUS: on_fail_status
          ) do
            CheckAction.new.call
          end
        end
      end
    end

    context "for Pull Requests" do
      it "Fails when coverage is lower than minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = "100"

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_pull_request.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token,
          INPUT_ON_FAIL_STATUS: on_fail_status
        ) do
          CheckAction.new.call
        end
      end

      it "Passes when coverage is greater than or equal to minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = "80"

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum coverage for suite\n\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify(
          GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_pull_request.json",
          GITHUB_SHA: sha,
          GITHUB_REPOSITORY: repo,
          INPUT_CHECK_JOB_NAME: "SimpleCov",
          INPUT_COVERAGE_PATH: "specs/fakes/fake_last_run.json",
          INPUT_COVERAGE_JSON_PATH: "specs/fakes/xx_not_a_file.json",
          INPUT_MINIMUM_SUITE_COVERAGE: minimum_coverage,
          INPUT_MINIMUM_FILE_COVERAGE: minimum_coverage,
          INPUT_GITHUB_TOKEN: github_token
        ) do
          CheckAction.new.call
        end
      end
    end
  end
end
