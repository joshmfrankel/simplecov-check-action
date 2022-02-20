# frozen_string_literal: true

require "./specs/spec_helper"

describe "Integration test" do
  let(:github_token) { "hzI7onpyGIGAjg==" }

  it "Fails when coverage is lower than minimum" do
    # Silence stdout
    expect($stdout).to receive(:write).at_least(:once)
    mock_request = instance_double(Request)
    expect(Request).to receive(:new).and_return(mock_request)
    expect(mock_request).to receive(:post).and_return("stuff")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "90",
      github_token: github_token,
      sha: "ssssss"
    )

    expect { action.call }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end
  end

  it "Passes when coverage is greater than or equal to minimum" do
    # Silence stdout
    expect($stdout).to receive(:write).at_least(:once)
    mock_request = instance_double(Request)
    expect(Request).to receive(:new).and_return(mock_request)
    expect(mock_request).to receive(:post).and_return("stuff")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "80",
      github_token: github_token,
      sha: "ssssss"
    )

    expect { action.call }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(0)
    end
  end
end
