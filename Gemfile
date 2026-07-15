source "https://rubygems.org"

group :development do
  gem "rubocop"
end

group :test do
  gem "pry"
  gem "pry-nav"
  gem "rspec"
  gem "webmock"
  if ENV["SIMPLECOV_REQUIREMENT"]
    gem "simplecov", ENV.fetch("SIMPLECOV_REQUIREMENT")
  else
    gem "simplecov"
  end
  gem "climate_control"

  # Optional for more robust reporting
  gem "simplecov-json" unless ENV["SIMPLECOV_JSON_FORMATTER"] == "false"
end
