source ENV['GEM_SOURCE'] || 'https://rubygems.org'

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
  gem 'listen', '<=3.0.3'
  gem 'rake', '~> 10.1.0'
  gem 'rspec', '~> 3.0.0'
  gem 'rspec-mocks', '~> 3.0.0'
  gem 'simplecov'
  gem 'yard'
  gem 'redcarpet', '~> 3.1.2'
  gem 'pry',                     require: false
  gem 'pry-doc',                 require: false
  gem 'pry-stack_explorer',      require: false
  gem 'rbeapi', '1.0', path: '.'
  gem 'ci_reporter_rspec',       require: false
  gem 'simplecov-json',          require: false
  gem 'simplecov-rcov',          require: false
end

# Rubocop > 0.37 requires a gem that only works with ruby 2.x
if RUBY_VERSION.to_f < 2.0
  gem 'json', '<2.0'
  group :development, :test do
    gem 'rubocop', '>=0.35.1', '< 0.38'
  end
else
  gem 'json'
  group :development, :test do
    gem 'rubocop', '>=0.35.1'
  end
end

# vim:ft=ruby
