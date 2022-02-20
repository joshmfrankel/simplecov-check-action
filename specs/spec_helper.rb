# frozen_string_literal: true

require "webmock/rspec"
require "json"
require "pry"
Dir["./lib/coverage/**/*.rb"].each do |file|
  require file
end
