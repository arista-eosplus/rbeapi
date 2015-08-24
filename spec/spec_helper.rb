# encoding: utf-8

require 'simplecov'
require 'simplecov-json'
require 'simplecov-rcov'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/.bundle/'
end

require 'pry'
require 'rbeapi'

dir = File.expand_path(File.dirname(__FILE__))
Dir["#{dir}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.include FixtureHelpers

  # rspec configuration
  config.mock_with :rspec do |rspec_config|
    rspec_config.syntax = :expect
  end
end
