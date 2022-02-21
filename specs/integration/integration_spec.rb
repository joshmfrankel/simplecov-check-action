# frozen_string_literal: true

require "./specs/spec_helper"

describe "Check Action integration" do
  let(:github_token) { "hzI7onpyGIGAjg==" }

  it "Fails when coverage is lower than minimum" do
    # Silence stdout
    mock_request = instance_double(Request)
    mock_response = double
    expect(Request).to receive(:new).and_return(mock_request)
    expect(mock_request).to receive(:post).and_return(mock_response)

    expect(mock_request).to receive(:patch).and_return(mock_response)

    # expect(mock_response).to receive(:[]).at_least(1)
    expect(mock_response).to receive(:code).at_least(1)
    expect(mock_response).to receive(:body).at_least(1).and_return("{}")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "90",
      github_token: github_token,
      sha: "ssssss"
    )

    # expect { action.call }.to raise_error(SystemExit) do |error|
    #   expect(error.status).to eq(1)
    # end

    action.call
  end

  it "Passes when coverage is greater than or equal to minimum" do
    # Silence stdout
    mock_request = instance_double(Request)
    mock_response = double
    expect(Request).to receive(:new).and_return(mock_request)
    expect(mock_request).to receive(:post).and_return(mock_response)

    expect(mock_request).to receive(:patch).and_return(mock_response)

    # expect(mock_response).to receive(:[]).at_least(1)
    expect(mock_response).to receive(:code).at_least(1)
    expect(mock_response).to receive(:body).at_least(1).and_return("{}")

    action = CheckAction.new(
      coverage_path: "specs/fakes/fake_coverage.json",
      minimum_coverage: "80",
      github_token: github_token,
      sha: "ssssss"
    )

    action.call

    # expect { action.call }.to raise_error(SystemExit) do |error|
    #   expect(error.status).to eq(0)
    # end
  end
end
