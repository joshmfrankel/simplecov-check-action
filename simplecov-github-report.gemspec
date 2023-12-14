# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'simplecov-github-report'
  s.version = '0.1.0'
  s.summary = 'Report Simplecov result to github as comment'
  s.description = 'Report Simplecov result to github as comment'
  s.authors = ['https://github.com/super-studio']
  all_files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.files         = all_files.grep(%r{^(exe|lib|rubocop)/|^.rubocop.yml$})
  s.require_paths = ['lib']

  s.metadata      = {
    'source_code_uri' => 'https://github.com/super-studio/simplecov-github-report',
    'bug_tracker_uri' => 'https://github.com/super-studio/simplecov-github-report/issues',
    'changelog_uri' => 'https://github.com/super-studio/simplecov-github-report/releases',
    'homepage_uri' => 'https://github.com/super-studio/simplecov-github-report'
  }

  s.required_ruby_version     = '>= 2.5.0'
  s.required_rubygems_version = '>= 2.7.0'
end
