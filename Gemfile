source ENV['GEM_SOURCE'] || 'https://rubygems.org'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbeapi/version'

gem 'inifile'
gem 'net_http_unix'
gem 'netaddr'

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem "rubocop", ">= 0.49.0"
  gem 'guard-shell'
end

group :development, :test do
  gem 'ci_reporter_rspec', require: false
  gem 'github_changelog_generator', :git => 'https://github.com/skywinder/github-changelog-generator.git'
  gem 'listen', '<=3.0.3'
  gem 'pry',                     require: false
  gem 'pry-doc',                 require: false
  gem 'pry-stack_explorer', require: false
  gem 'rake', '~> 12.3.3'
  gem 'rbeapi', Rbeapi::VERSION, path: '.'
  gem 'redcarpet', '~> 3.5.1'
  gem 'rspec', '~> 3.0.0'
  gem 'rspec-mocks', '~> 3.0.0'
  gem 'simplecov'
  gem 'simplecov-json',          require: false
  gem 'simplecov-rcov',          require: false
  gem 'yard'
end

# Rubocop thinks these are duplicates.
# rubocop:disable Bundler/DuplicatedGem
gem 'json'
group :development, :test do
  gem 'rubocop', '>=0.49.0'
end

# vim:ft=ruby
