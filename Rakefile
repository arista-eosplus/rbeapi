require 'bundler/gem_tasks'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'rbeapi/version'

task :build do
    system "gem build rbeapi.gemspec"
end

task :release => :build do
    system "gem push rbeapi-#{Rbeapi::VERSION}"
end
