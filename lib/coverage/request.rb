# frozen_string_literal: true

require "net/http"

class Request
  def initialize(access_token:)
    @access_token = access_token
  end

  def post(uri:, body:)
    uri = URI.parse(uri)
    request_object = Net::HTTP::Post.new(uri).tap do |request|
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/vnd.github.antiope-preview+json"
      request["Authorization"] = "Bearer #{@access_token}"
      request["User-Agent"] = "Coverage"

      request.body = body.to_json
    end

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request_object)
    end
  end
end
