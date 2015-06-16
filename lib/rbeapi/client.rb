#
# Copyright (c) 2014, 2015 Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'inifile'

require 'rbeapi/utils'
require 'rbeapi/eapilib'
require 'rbeapi/api'

##
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::Client
  module Client
    class << self
      DEFAULT_TRANSPORT = 'http'

      TRANSPORTS = { 'http' => 'Rbeapi::Eapilib::HttpEapiConnection',
                     'https' => 'Rbeapi::Eapilib::HttpsEapiConnection',
                     'http_local' => 'Rbeapi::Eapilib::HttpLocalEapiConenction',
                     'socket' => 'Rbeapi::Eapilib::SocketEapiConnection' }

      ##
      # Returns the currently loaded config object.  This function will
      # create a new instance of the config object if one doesn't already
      # exist
      #
      # @return [Config] Returns an instance of Config used for working
      #   with the eapi.conf file
      def config
        return @config if @config
        @config = Config.new
        @config
      end

      ##
      # load_config overrides the default conf file loaded in the config
      # instances using the supplied conf argument as the conf file.  This
      # method will clear out an previously loaded configuration and replace
      # all entries with the contents of the supplied file.
      #
      # @param [String] :conf The full path to the conf file to load into
      #   the config instance.
      def load_config(conf)
        config.read(conf)
      end

      ##
      # Returns the configuration options for the named connection from
      # the loaded configuration.  The configuration name is specified as
      # the string right of the colon in the section name.
      #
      # @param [String] :name The connection name to return from the loaded
      #   configuration
      #
      # @return [Hash, nil] This method will return the configuration hash for
      #   the named configuration if found.  If the name is not found, then
      #   nil is returned
      def config_for(name)
        config.get_connection(name)
      end

      ##
      # Retrieves the node config form the loaded configuration file and
      # returns a Rbeapi::Node instance for working with the remote node.
      #
      # @param [String] :name The named configuration to use for creating the
      #   connection to the remote node
      #
      # @return [Rbeapi::Node, nil] Returns an instance of Rbeapi::Node.  If
      #   the named configuration is not found then nil is returned
      def connect_to(name)
        config = config_for(name)
        return nil unless config
        config = Rbeapi::Utils.transform_keys_to_symbols(config)
        connection = connect config
        Node.new(connection)
      end

      ##
      # Builds a connection object to a remote node using the specified
      # options and return an instance of Rbeapi::Connection.  All
      # configuration options can be passed via the :opts param or can be
      # overridden using environment variables.  Environment variables are
      # specified by prepending EAPI to the option name.  For instance to
      # override the host param use EAPI_HOST.
      #
      # @param [Hash] :opts the options to create a message with
      # @option :opts [String] :host The IP address or hostname of the remote
      #   eAPI endpoint
      # @option :opts [String] :username The username to use to authenticate
      #   the eAPI connection with
      # @option :opts [String] :password The password to use to authenticate
      #   the eAPI connection with
      # @option :opts [String] :enable_pwd The enable password (if defined) to
      #   pass to the remote node to enter privilege mode
      # @option :opts [String] :use_ssl Specifies whether or not to use the
      #   HTTP or HTTPS protocol
      # @option :opts [String] :port The port to connect to.  If not specified
      #   The port is automatically determined based on the protocol used
      #   (443 for https, 80 for http)
      #
      # @return [Rbeapi::Connection] Returns an instance of Rbeapi::Connection
      #   using the specified configuration options
      def connect(opts = {})
        transport = opts.fetch(:transport, DEFAULT_TRANSPORT)
        make_connection(transport, opts)
      end

      ##
      # Creates a connection instance that can either be used directly or
      # passed to a Node instance.
      #
      # @params [String] :transport The name of the transport to create.
      # @params [Hash] :opts The options used to create the transport
      #
      # @return [Rbeapi::EapiConnection] A instance of a connection object
      def make_connection(transport, opts = {})
        klass = TRANSPORTS.fetch(transport)
        cls = Rbeapi::Utils.class_from_string(klass)
        cls.new(opts)
      end
    end

    ##
    # The Config class holds the loaded configuration file data.  It is a
    # subclass of IniFile.
    class Config < IniFile
      CONFIG_SEARCH_PATH = ['~/.eapi.conf', '/mnt/flash/eapi.conf']

      ##
      # The Config class will automatically search for a filename to load
      # (if none provided) and load the data when the object is instantiated.
      #
      # @param [String] :filename The full path to the filename to load.  If
      #   the filename is not provided, then this class will attempt to find
      #   a valid conf file using the CONFIG_SEARCH_PATH.
      def initialize(opts = {})
        super(parameter: ':')
        @filename = opts.fetch(:filename, nil)
        autoload
      end

      ##
      # This private method automatically finds and loads the conf file
      # into the instance using the class variable CONFIG_SEARCH_PATH.  The
      # connections should be retrieved using the get_connection method
      #
      # @param [Hash] :opts The options for specifying the message
      # @option :opts [String] :filename The full path to the filename
      #   to load.  Using this option eliminates the use of the
      #   search path
      def autoload(opts = {})
        search_path = CONFIG_SEARCH_PATH.dup
        search_path.insert(0, ENV['EAPI_CONF']) if ENV.key?('EAPI_CONF')

        path = opts[:filename] || search_path

        path.each do |fn|
          fn = File.expand_path(fn)
          return read(fn) if File.exist?(fn)
        end

        return if get_connection 'localhost'
        add_connection('localhost', transport: 'socket')
      end
      private :autoload

      ##
      # This method will read the specified filename and load its contents
      # into the instance.  It will also add the default localhost entry
      # if it doesn't exist in the conf file
      #
      # @param [String] :filename The full path to the filename to load
      def read(filename)
        super(filename: filename)

        # For each section, if the host parameter is omitted then the
        # connection name is used
        sections.each do |name|
          if name.start_with?('connection:')
            conn = self["#{name}"]
            conn['host'] = name.split(':')[1] unless conn['host']
          end
        end

        return if get_connection 'localhost'
        add_connection('localhost', transport: 'socket')
      end

      ##
      # This method will cause the config to be loaded.  The process of
      # finding the configuration will be repeated so it is possible a
      # different conf file could be chosen if the original file was
      # removed or a new file added higher on the search priority list
      #
      # @param [Hash] :opts The options for specifying the message
      # @opton :opts [String] :filename The full path to the file to load
      def reload(opts = {})
        autoload opts
      end

      ##
      # Returns the configuration for the connection specified
      #
      # @param [String] :name The name of the connection to return from
      #   the configuration.  This should be the string right of the :
      #   in the config section header
      #
      # @return [nil, Hash<String, String> Returns a hash of the connection
      #   properties from the loaded config.  This method will return nil
      #   if the connection name is not found.
      def get_connection(name)
        return nil unless sections.include? "connection:#{name}"
        self["connection:#{name}"]
      end

      ##
      # Adds a new connection section  to the current configuration
      #
      # @param [String] :name The name of the connection to add to the
      #   configuration.
      # @param [Hash] :values The properties for the connection
      def add_connection(name, values)
        self["connection:#{name}"] = values
      end
    end

    ##
    # The Node object provides an instance for sending and receiving messages
    # with a specific EOS device. The methods provided in this class allow
    # for handling both enable mode and config mode commands
    class Node
      attr_reader :connection

      ##
      # Save the connection and set autorefresh to true.
      #
      # @param [Rbeapi::Eapilib::EapiConnection] :connection An instance of
      #   EapiConnection used to send and receive eAPI formatted messages
      def initialize(connection)
        @connection = connection
        @autorefresh = true
      end

      ##
      # Provides access the nodes running-configuration. This is a lazily
      # loaded memoized property for working with the node configuration
      #
      # @return [String] The node's running-config as a string
      def running_config
        return @running_config if @running_config
        @running_config = get_config(params: 'all', as_string: true)
      end

      ##
      # Provides access to the nodes startup-configuration.  This is a lazily
      # loaded memoized property for working with the nodes startup config
      #
      # @return [String] The node's startup-config as a string
      def startup_config
        return @startup_config if @startup_config
        @startup_config = get_config(config: 'startup-config', as_string: true)
      end

      ##
      # Configures the node instance to use an enable password.  EOS can be
      # configured to require a second layer of authentication when putting
      # the session into enable mode.  The password supplied will be used to
      # authenticate the session to enable mode if necessary.
      #
      # @param [String] :password The value of the enable password
      def enable_authentication(password)
        @enablepwd = password
      end

      ##
      # The config method is a convenience method that will handling putting
      # the switch into config mode prior to executing commands.  The method
      # will insert 'config' at the top of the command stack and then pop
      # the empty hash from the response output before return the array
      # to the caller
      #
      # @param [Array<String>] commands An ordered list of commands to execute
      #
      # @return [Array<Hash>] ordered list of output from commands
      def config(commands)
        commands = [*commands] unless commands.respond_to?('each')

        commands.insert(0, 'configure')
        response = run_commands commands

        refresh if @autorefresh

        response.shift
        response
      end

      ##
      # The enable method is a convenience method that will handling putting
      # the switch into privilege mode prior to executing commands.
      #
      # rubocop:disable Metrics/MethodLength
      #
      # @param [Array<String>] commands An ordered list of commands to execute
      # @param [String] :encoding The encoding scheme to use for sending and
      #   receive eAPI messages.  Valid values are json and text.  The default
      #   value is json
      #
      # @return [Array<Hash>] ordered list of output from commands
      def enable(commands, opts = {})
        commands = [*commands] unless commands.respond_to?('each')

        encoding = opts.fetch(:encoding, 'json')
        strict = opts.fetch(:strict, false)
        open_timeout = opts.fetch(:open_timeout, 10)
        read_timeout = opts.fetch(:read_timeout, 10)

        results = []
        if strict
          responses = run_commands(commands, encoding, open_timeout,
                                   read_timeout)
          responses.each_with_index do |resp, idx|
            results << make_response(commands[idx], resp, encoding)
          end
        else
          commands.each do |cmd|
            begin
              response = run_commands(cmd, encoding, open_timeout, read_timeout)
              results << make_response(cmd, response.first, encoding)
            rescue Rbeapi::Eapilib::CommandError => exc
              raise unless exc.error_code == 1003
              response = run_commands(cmd, 'text', open_timeout, read_timeout)
              results << make_response(cmd, response.first, encoding)
            end
          end
        end
        results
      end

      ##
      # Returns a response object from a call to the enable method.  This
      # private method is an internal method to ensure consistency in the
      # return message format
      #
      # @param [String] :command The command send to the node
      # @param [Hash] :response The response returned from the eAPI call
      # @param [String] :encoding The encoding scheme used in the response
      #   which should be either json or text
      #
      # @return [Hash] A Ruby hash object
      def make_response(command, result, encoding)
        { command: command, result: result, encoding: encoding }
      end
      private :make_response

      ##
      # This method will send the ordered list of commands to the destination
      # node using the transport.  It is also response for inserting enable
      # onto the command stack and popping the enable result on the response
      #
      # @param [Array] :commands The ordered list of commands to send to the
      #   destination node.
      # @param [String] :encoding The encoding scheme to use for sending and
      #   receive eAPI requests.  This argument is optional.  Valid values
      #   include json or text.  The default is json
      def run_commands(commands, encoding = 'json', open_timeout = 10,
                       read_timeout = 10)
        commands = [*commands] unless commands.respond_to?('each')
        commands = commands.dup

        if @enablepwd
          commands.insert(0, 'cmd' => 'enable', 'input' => @enablepwd)
        else
          commands.insert(0, 'enable')
        end

        response = @connection.execute(commands, format: encoding,
                                                 open_timeout: open_timeout,
                                                 read_timeout: read_timeout)
        response.shift
        response
      end

      ##
      # This method will retrieve the specified configuration from the node
      # and return it in full text.
      #
      # @param [Hash] opts the options to create a message with
      # @option :opts [String] :config The configuration instance to return from
      #   the node.  Valid values are 'running-config' and 'startup-config'. If
      #   no value is specified, then 'running-config' is used
      # @ :opts [String] :param Additional parameters to append to the
      #   retrieving the configuration.  Valid values depend on the config
      #   file requested
      #
      #   running-config params
      #     all         Configuration with defaults
      #     detail      Detail configuration with defaults
      #     diffs       Differences from startup-config
      #     interfaces  Filter config to include only the given interfaces
      #     sanitized   Sanitized Output
      #     section     Display sections containing matching commands
      #
      #   startup-config params
      #     errors      Show information about the errors in startup-config
      #     interfaces  Filter config to include only the given interfaces
      #     section     Display sections containing matching commands
      #
      # @return [String] the specified configuration as text
      def get_config(opts = {})
        config = opts.fetch(:config, 'running-config')
        params = opts.fetch(:params, '')
        as_string = opts.fetch(:as_string, false)
        result = run_commands("show #{config} #{params}", 'text')
        return result.first['output'].strip.split("\n") unless as_string
        result.first['output'].strip
      end

      ##
      # Returns an API module for working with the active configuration
      # of the node
      def api(name, opts = {})
        path = opts.fetch(:path, 'rbeapi/api')
        namespace = opts.fetch(:namespace, 'Rbeapi::Api')
        require "#{path}/#{name}"
        clsname = "#{namespace}::#{name.capitalize}"
        cls = Rbeapi::Utils.class_from_string(clsname)
        return cls.instance(self) if cls.respond_to?(:instance)
        cls.new(self)
      end

      ##
      # Forces both the running-config and startup-config to be refreshed on
      # the next call to those properties.
      def refresh
        @running_config = nil
        @startup_config = nil
      end
    end
  end
end
