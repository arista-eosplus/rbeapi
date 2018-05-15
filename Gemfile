source ENV['GEM_SOURCE'] || 'https://rubygems.org'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbeapi/version'

gem 'json'
gem 'inifile'
gem 'net_http_unix'
gem 'netaddr'

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-shell'
end

group :development, :test do
  gem 'ci_reporter_rspec', require: false
  gem 'github_changelog_generator', :git => 'https://github.com/skywinder/github-changelog-generator.git'
  gem 'listen', '<=3.0.3'
  gem 'pry',                     require: false
  gem 'pry-doc',                 require: false
  gem 'pry-stack_explorer', require: false
  gem 'rake', '~> 10.1.0'
  gem 'rbeapi', Rbeapi::VERSION, path: '.'
  gem 'redcarpet', '~> 3.1.2'
  gem 'rspec', '~> 3.0.0'
  gem 'rspec-mocks', '~> 3.0.0'
  gem 'rubocop', '>=0.35.1'
  gem 'simplecov'
  gem 'simplecov-json',          require: false
  gem 'simplecov-rcov',          require: false
  gem 'yard'
end

# vim:ft=ruby
