# simplecov-check-action

## Installation

```ruby
# Gemfile
group :test do
  gem "simplecov", require: false
  gem 'simplecov-json', :require => false
end

# test/test_helper.rb
require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
```
