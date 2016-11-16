# encoding: utf-8

require 'pathname'
require 'yaml'
require 'json'

##
# Fixtures implements a global container to store fixture data loaded from the
# filesystem.
class Fixtures
  def self.[](name)
    @fixtures[name]
  end

  def self.[]=(name, value)
    @fixtures[name] = value
  end

  def self.clear
    @fixtures = {}
  end

  clear

  ##
  # save an object and saves it as a fixture in the filesystem.
  #
  # @param [Symbol] key The fixture name without the `fixture_` prefix or
  #   `.json` suffix.
  #
  # @param [Object] obj The object to serialize to JSON and write to the
  #   fixture file.
  #
  # @option opts [String] :dir ('/path/to/fixtures') The fixtures directory,
  #   defaults to the full path of spec/fixtures/ relative to the root of the
  #   module.
  def self.save(key, obj, opts = {})
    dir = opts[:dir] || File.expand_path('../../fixtures', __FILE__)
    file = Pathname.new(File.join(dir, "fixture_#{key}.yaml"))
    raise ArgumentError, "Error, file #{file} exists" if file.exist?
    File.open(file, 'w+') { |f| f.puts YAML.dump(obj) }
  end
end

##
# FixtureHelpers provides instance methods for RSpec test cases that aid in the
# loading and caching of fixture data.
module FixtureHelpers
  ##
  # fixture loads a JSON fixture from the spec/fixtures/ directory, prefixed
  # with fixture_.  Given the name 'foo' the file
  # `spec/fixtures/fixture_foo.json` will be loaded and returned.  This method
  # is memoized across the life of the process.
  #
  # rubocop:disable Metrics/MethodLength,
  #
  # @param [Symbol] key The fixture name without the `fixture_` prefix or
  #   `.json` suffix.
  #
  # @option opts [String] :dir ('/path/to/fixtures') The fixtures directory,
  #   defaults to the full path of spec/fixtures/ relative to the root of the
  #   module.
  #
  # @option opts [String] :format (:ruby) The format to return the fixture in,
  #   defaults to native Ruby objects.  :json will return a JSON string.
  def fixture(key, opts = { format: :ruby })
    if opts[:format] == :ruby
      memo = Fixtures[key]
      return memo if memo
    end
    dir = opts[:dir] || fixture_dir

    yaml = Pathname.new(File.join(dir, "fixture_#{key}.yaml"))
    json = Pathname.new(File.join(dir, "fixture_#{key}.json"))
    text = Pathname.new(File.join(dir, "fixture_#{key}.text"))

    data = if yaml.exist?; then YAML.load(File.read(yaml))
           elsif json.exist?; then JSON.load(File.read(json))
           elsif text.exist?; then File.read(text)
           else raise "could not load YAML, JSON or TEXT fixture #{key} "\
             "tried:\n  #{yaml}\n  #{json} #{text}"
           end

    Fixtures[key] = data

    case opts[:format]
    when :ruby then data
    when :json then JSON.pretty_generate(data)
    when :yaml then YAML.dump(data)
    when :text then data
    else raise ArgumentError, "unknown format #{opts[:format].inspect}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  ##
  # fixture_dir returns the full path to the fixture directory
  #
  # @api public
  #
  # @return [String] the full path to the fixture directory
  def fixture_dir
    File.expand_path('../../fixtures', __FILE__)
  end

  ##
  # fixture_file returns the full path to a file in the fixture directory
  #
  # @api public
  #
  # @return [String] the full path to the fixture file
  def fixture_file(name)
    File.join(fixture_dir, name)
  end
end
