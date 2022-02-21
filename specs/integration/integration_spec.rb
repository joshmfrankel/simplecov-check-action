# frozen_string_literal: true

require "./specs/spec_helper"

describe "Check Action integration" do
  let(:github_token) { "hzI7onpyGIGAjg==" }
  let(:check_run_id) { 1 }
  let(:sha) { "foobarbaz" }
  let(:the_time) { "2022-02-21T09:51:57-05:00" }
  let(:repo) { "robswire/immersion" }

  context "for coverage type line" do
    it "raises RuntimeError when coverage file doesn't contain `line` key" do
      minimum_coverage = 100

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_bad_format.json",
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

    it "Fails when coverage is lower than minimum" do
      mock_time = instance_double(Time)
      expect(Time).to receive(:now).and_return(mock_time).twice
      expect(mock_time).to receive(:iso8601).and_return(the_time).twice
      minimum_coverage = 100

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "Coverage Results", summary: "* 97.77% covered\n" + "* #{minimum_coverage}% minimum (by line)\n", text: "The text", annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "line",
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
      minimum_coverage = 80

      stub_request(:post, "https://api.github.com/repos/#{repo}/check-runs")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "Coverage Results", summary: "* 97.77% covered\n" + "* #{minimum_coverage}% minimum (by line)\n", text: "The text", annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
        minimum_coverage: minimum_coverage,
        minimum_coverage_type: "line",
        github_token: github_token,
        sha: sha,
        repo: repo
      )

      action.call
    end
  end

  context "for coverage type branch" do
    it "raises RuntimeError when coverage file doesn't contain `branch` key" do
      minimum_coverage = 100

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_bad_format.json",
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
        .with(body: { name: "Coverage Results", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "failure", output: { title: "Coverage Results", summary: "* 75.0% covered\n" + "* #{minimum_coverage}% minimum (by branch)\n", text: "The text", annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
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
        .with(body: { name: "Coverage Results", head_sha: sha, status: "in_progress", started_at: the_time })
        .to_return(body: { id: check_run_id }.to_json, status: 201)

      stub_request(:patch, "https://api.github.com/repos/#{repo}/check-runs/#{check_run_id}")
        .with(body: { name: "Coverage Results", head_sha: sha, status: "completed", completed_at: the_time, conclusion: "success", output: { title: "Coverage Results", summary: "* 75.0% covered\n" + "* #{minimum_coverage}% minimum (by branch)\n", text: "The text", annotations: [] } })

      action = CheckAction.new(
        coverage_path: "specs/fakes/fake_last_run.json",
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
