# frozen_string_literal: true

require "./specs/spec_helper"

describe "Check Action integration" do
  let(:github_token) { "hzI7onpyGIGAjg==" }
  let(:check_run_id) { 1 }

  it "Fails when coverage is lower than minimum" do
    stub_request(:post, "https://api.github.com/repos/joshmfrankel/simplecov-check-action/check-runs")
      .to_return(body: { id: check_run_id }.to_json)
    stub_request(:patch, "https://api.github.com/repos/joshmfrankel/simplecov-check-action/check-runs/#{check_run_id}")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "90",
      github_token: github_token,
      sha: "ssssss"
    )

    action.call
  end

  it "Passes when coverage is greater than or equal to minimum" do
    stub_request(:post, "https://api.github.com/repos/joshmfrankel/simplecov-check-action/check-runs")
      .to_return(body: { id: check_run_id }.to_json)
    stub_request(:patch, "https://api.github.com/repos/joshmfrankel/simplecov-check-action/check-runs/#{check_run_id}")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "80",
      github_token: github_token,
      sha: "ssssss"
    )

    action.call
  end
end
