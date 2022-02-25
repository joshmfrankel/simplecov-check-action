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
  let(:passing_markdown_text) { "Nothing to show" }

  context "for coverage type line" do
    it "raises RuntimeError when coverage file doesn't contain `line` key" do
      mock_time = instance_double(Time)
      expect(Time).to receive(:now).and_return(mock_time)
      expect(mock_time).to receive(:iso8601).and_return(the_time)
      minimum_coverage = 100

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_bad_format.json",
        coverage_json_path: "specs/fakes/xx_not_a_file.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "line",
        github_token: github_token,
        sha: sha,
        repo: repo
      )

      expect {
        action.call
      }.to raise_error(RuntimeError)
    end

    context "for Pushes" do
      it "Fails when coverage is lower than minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = 100

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json", GITHUB_SHA: sha do
          CheckAction.new(
            coverage_path: "specs/fakes/fake_last_run.json",
            coverage_json_path: "specs/fakes/xx_not_a_file.json",
            minimum_coverage: minimum_coverage,
            minimum_coverage_type: "line",
            github_token: github_token,
            sha: RetrieveCommitSha.call,
            repo: repo
          ).call
        end
      end

      it "Passes when coverage is greater than or equal to minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = 80

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json", GITHUB_SHA: sha do
          CheckAction.new(
            coverage_path: "specs/fakes/fake_last_run.json",
            coverage_json_path: "specs/fakes/xx_not_a_file.json",
            minimum_coverage: minimum_coverage,
            minimum_coverage_type: "line",
            github_token: github_token,
            sha: RetrieveCommitSha.call,
            repo: repo
          ).call
        end
      end

      context "when SimpleCov-json coverage file is present" do
        it "Passes when all file coverages are above minimum" do
          mock_time = instance_double(Time)
          expect(Time).to receive(:now).and_return(mock_time).twice
          expect(mock_time).to receive(:iso8601).and_return(the_time).twice
          minimum_coverage = 49 # 50 is lowest in fake file

          stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
            .to_return(body: { id: check_run_id }.to_json, status: 201)

          stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
            .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: passing_markdown_text, annotations: [] } })

          ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json", GITHUB_SHA: sha do
            CheckAction.new(
              coverage_path: "specs/fakes/fake_last_run.json",
              coverage_json_path: "specs/fakes/optional_fake_simplecov_json.json",
              minimum_coverage: minimum_coverage,
              minimum_coverage_type: "line",
              github_token: github_token,
              sha: RetrieveCommitSha.call,
              repo: repo
            ).call
          end
        end

        it "Fails when coverage is lower than minimum and prints failing files" do
          mock_time = instance_double(Time)
          expect(Time).to receive(:now).and_return(mock_time).twice
          expect(mock_time).to receive(:iso8601).and_return(the_time).twice
          minimum_coverage = 99
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
            .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "4 file(s) below minimum #{minimum_coverage}.0% coverage", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: failing_markdown_text, annotations: [] } })

          ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_push.json", GITHUB_SHA: sha do
            CheckAction.new(
              coverage_path: "specs/fakes/fake_last_run.json",
              coverage_json_path: "specs/fakes/optional_fake_simplecov_json.json",
              minimum_coverage: minimum_coverage,
              minimum_coverage_type: "line",
              github_token: github_token,
              sha: RetrieveCommitSha.call,
              repo: repo
            ).call
          end
        end
      end
    end

    context "for Pull Requests" do
      it "Fails when coverage is lower than minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = 100

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_pull_request.json", GITHUB_SHA: "invalid" do
          CheckAction.new(
            coverage_path: "specs/fakes/fake_last_run.json",
            coverage_json_path: "specs/fakes/xx_not_a_file.json",
            minimum_coverage: minimum_coverage,
            minimum_coverage_type: "line",
            github_token: github_token,
            sha: RetrieveCommitSha.call,
            repo: repo
          ).call
        end
      end

      it "Passes when coverage is greater than or equal to minimum" do
        mock_time = instance_double(Time)
        expect(Time).to receive(:now).and_return(mock_time).twice
        expect(mock_time).to receive(:iso8601).and_return(the_time).twice
        minimum_coverage = 80

        stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "in_progress", started_at: the_time })
          .to_return(body: { id: check_run_id }.to_json, status: 201)

        stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
          .with(body: { name: "SimpleCov", head_sha: pull_request_json_sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "97.77% covered (minimum #{minimum_coverage}.0%)", summary: "* 97.77% covered\n" + "* #{minimum_coverage}.0% minimum (by line)\n", text: passing_markdown_text, annotations: [] } })

        ClimateControl.modify GITHUB_EVENT_PATH: "specs/fakes/fake_github_event_path_pull_request.json", GITHUB_SHA: "garbage" do
          CheckAction.new(
            coverage_path: "specs/fakes/fake_last_run.json",
            coverage_json_path: "specs/fakes/xx_not_a_file.json",
            minimum_coverage: minimum_coverage,
            minimum_coverage_type: "line",
            github_token: github_token,
            sha: RetrieveCommitSha.call,
            repo: repo
          ).call
        end
      end
    end
  end

  context "for coverage type branch" do
    it "raises RuntimeError when coverage file doesn't contain `branch` key" do
      mock_time = instance_double(Time)
      expect(Time).to receive(:now).and_return(mock_time)
      expect(mock_time).to receive(:iso8601).and_return(the_time)
      minimum_coverage = 100

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_bad_format.json",
        coverage_json_path: "specs/fakes/xx_not_a_file.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "branch",
        github_token: github_token,
        sha: sha,
        repo: repo
      )

      expect {
        action.call
      }.to raise_error(RuntimeError)
    end

    it "Fails when coverage is lower than minimum" do
      mock_time = instance_double(Time)
      expect(Time).to receive(:now).and_return(mock_time).twice
      expect(mock_time).to receive(:iso8601).and_return(the_time).twice
      minimum_coverage = 100

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "75.0% covered (minimum #{minimum_coverage}.0%)", summary: "* 75.0% covered\n" + "* #{minimum_coverage}.0% minimum (by branch)\n", text: passing_markdown_text, annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
        coverage_json_path: "specs/fakes/xx_not_a_file.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "branch",
        github_token: github_token,
        sha: sha,
        repo: repo
      )

      action.call
    end

    it "Passes when coverage is greater than or equal to minimum" do
      mock_time = instance_double(Time)
      expect(Time).to receive(:now).and_return(mock_time).twice
      expect(mock_time).to receive(:iso8601).and_return(the_time).twice
      minimum_coverage = 70

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "SimpleCov", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "75.0% covered (minimum #{minimum_coverage}.0%)", summary: "* 75.0% covered\n" + "* #{minimum_coverage}.0% minimum (by branch)\n", text: passing_markdown_text, annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
        coverage_json_path: "specs/fakes/xx_not_a_file.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "branch",
        github_token: github_token,
        sha: sha,
        repo: repo
      )

      action.call
    end
  end
end
