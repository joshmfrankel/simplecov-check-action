# frozen_string_literal: true

require "net/http"

class Request
  def initialize(access_token:, debug:)
    @access_token = access_token
    @debug = debug
  end

  # Make HTTP Patch request
  # @param uri: [String|URI] The endpoint to make the request at
  # @param body: [Hash] The payload to send to the endpoint
  #
  # @return [Net::HTTPResponse]
  def post(uri:, body:)
    run(method: Net::HTTP::Post, uri: uri, body: body)
  end

  # Make HTTP Patch request
  # @param uri: [String|URI] The endpoint to make the request at
  # @param body: [Hash] The payload to send to the endpoint
  #
  # @return [Net::HTTPResponse]
  def patch(uri:, body:)
    run(method: Net::HTTP::Patch, uri: uri, body: body)
  end

  private

  def run(method:, uri:, body:)
    uri = URI.parse(uri)
    request_object = method.new(uri).tap do |request|
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/vnd.github.antiope-preview+json"
      request["Authorization"] = "Bearer #{@access_token}"
      request["User-Agent"] = "Github Action"

      request.body = body.to_json
    end

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request_object)
    end

    if response.code.to_i >= 300
      raise "#{response.message}: #{response.body}"
    end

    if @debug
      $stdout.puts "#{response.message}: #{response.body}"
    end

    response
  end
end
