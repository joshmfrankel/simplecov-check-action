# SimpleCov Github Check Action

# Basic Installation
In order for simplecov-check-action to function properly, you first need the simplecov gem. See [Getting Started](https://github.com/simplecov-ruby/simplecov#getting-started).

Assuming you've followed the guide above (you have the gem in your Gemfile and have properly setup test_helper.rb), then the only other step is to utilize the Github action within your workflow.

```yml
  # However you run your tests to generate code coverage
  - name: Run my tests
    run: |
      bundle exec rspec specs/

  # Minimum configuration
  - uses: joshmfrankel/simplecov-check-action@main
    with:
      github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Sample Output

**Github PR Check UI**
![img/simple-cov-check-basic.png]

**Github Detailed Check UI**
![img/simple-cov-check-basic-detailed.png]

## Configuration Options
See [https://github.com/joshmfrankel/simplecov-check-action/blob/main/action.yml](https://github.com/joshmfrankel/simplecov-check-action/blob/main/action.yml) for all available options and their defaults.

Most useful is the **minimum_coverage** option as it allows specification as to the value at which a failure result should be produced.

# Advanced Installation
If you also configure the simplecov-json gem there are some additional benefits. See [Usage](https://github.com/vicentllongo/simplecov-json#usage) for simplecov-json.

Note: You'll need to setup both the standard formatter as well as json formatter within your test_helper.rb

```ruby
require "simplecov"
require "simplecov-json"
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])
SimpleCov.start do
  # your config
end
```

Now instead of checking overall test suite coverage, the Github Action will ensure that individual files have higher coverage than the minimum. This is essentially a reproduction of the built-in minimum_coverage_by_file option of SimpleCov albeit at the Github Action level. See [minimum_coverage_by_file](https://github.com/simplecov-ruby/simplecov#minimum-coverage-by-file)

## Sample Output

**Github PR Check UI**
![img/simple-cov-check-advanced.png]

**Github Detailed Check UI**
![img/simple-cov-check-advanced-detailed.png]
