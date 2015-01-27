# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbeapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbeapi'
  spec.version       = Rbeapi::VERSION
  spec.authors       = ['Peter Sprygada']
  spec.email         = ['sprygada@arista.com']
  spec.description   = 'Arista eAPI Ruby Library'
  spec.summary       = 'This Gem library provides a Ruby interface '\
                       'to the Arista EOS command API'
  spec.homepage      = 'https://github.com/arista-eosplus/rbeapi'
  spec.license       = 'New BSD'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'net_http_unix'
  spec.add_dependency 'inifile'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rake', '~> 10.1.0'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'rspec-mocks', '~> 3.0.0'
  spec.add_development_dependency 'simplecov'
end
