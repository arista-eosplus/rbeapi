source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gem 'inifile'
gem 'json'
gem 'net_http_unix'
gem 'netaddr'

group :development do
  gem 'rubocop', '>=0.35.1'
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
  gem 'rbeapi', '0.4.0', path: '.'
  gem 'ci_reporter_rspec',       require: false
  gem 'simplecov-json',          require: false
  gem 'simplecov-rcov',          require: false
end

# vim:ft=ruby
