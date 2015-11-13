#
# Copyright (c) 2014, 2015, Arista Networks, Inc.
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
require 'net/http'
require 'json'
require 'openssl'

require 'net_http_unix'

##
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::Eapilib
  module Eapilib
    DEFAULT_HTTP_PORT = 80
    DEFAULT_HTTPS_PORT = 443
    DEFAULT_HTTP_LOCAL_PORT = 8080
    DEFAULT_HTTP_OPEN_TIMEOUT = 10
    DEFAULT_HTTP_READ_TIMEOUT = 10
    DEFAULT_HTTP_PATH = '/command-api'
    DEFAULT_UNIX_SOCKET = '/var/run/command-api.sock'

    ##
    # Base error class for generating exceptions.  The EapiError class
    class EapiError < StandardError
      attr_accessor :commands

      ##
      # The EapiError class provides one property for holding the set of
      # commands issued when the error was generated.
      #
      # @param [String] :message The error message to return from raising
      #   the exception
      def initalize(message)
        @message = message
        @commands = nil
        super(message)
      end
    end

    ##
    # A CommandError exception is raised in response to an eAPI call that
    # returns a failure message.
    class CommandError < EapiError
      attr_reader :error_code
      attr_reader :error_text

      ##
      # The exception contains the eAPI error code and error text.
      #
      # @param [String] :message The error message to return from raising
      #   this exception
      # @param [Integer] :code The error code associated with the error
      #   message to be raised
      # @param [Array] :commands The list of commands that were used  in the
      #   eAPI request message
      def initialize(message, code, commands = nil)
        @error_code = code
        @error_text = message
        @commands = commands
        message = "Error [#{code}]: #{message}"
        super(message)
      end
    end

    ##
    # A ConnectionError exception is raised when the connection object
    # is unable to establish a connection with eAPI.
    class ConnectionError < EapiError
      attr_accessor :connection_type

      ##
      # The exception contains the eAPI error code and error text.
      #
      # @param [String] :message The error message to return from raising
      #   this exception
      # @param [String] :connection_type The optional connection_type of
      #   the instance
      # @param [Array] :commands The list of commands that were used  in the
      #   eAPI request message
      def initialize(message, connection_type = nil, commands = nil)
        @connection_type = connection_type
        @commands = commands
        super(message)
      end
    end

    ##
    # The EapiConnection provides a base class for building eAPI connection
    # instances with a specific transport for connecting to Arista EOS
    # devices.  This class handles sending and receiving eAPI calls using
    # JSON-RPC.  This class should not need to be directly instantiated.
    class EapiConnection
      attr_reader :error

      ##
      # The connection contains the transport.
      #
      # @param [Net::HTTP] :transport The HTTP transport to use for sending
      #   and receive eAPI request and response messages
      def initialize(transport)
        @transport = transport
        @error = nil
      end

      ##
      # Configures the connection authentication values (username and
      # password).  The authentication values are used to authenticate
      # the eAPI connection.  Using authentication is only required for
      # connections that use Http or Https transports
      #
      # @options :opts [String] :username The username to use to
      #   authenticate with eAPI. Default is 'admin'.
      # @options :opts [String] :password The password to use to
      #   authenticate with eAPI. Default is ''.
      def authentication(opts = {})
        @username = opts.fetch(:username, 'admin')
        @password = opts.fetch(:password, '')
      end

      ##
      # Configures the connection timeout values (open_timeout and
      # read_timeout).  The timeout values are used for the eAPI
      # connection.
      #
      # @option :opts [Float] :open_timeout Number of seconds to wait for the
      #   eAPI connection to open. Default is DEFAULT_HTTP_OPEN_TIMEOUT.
      # @option :opts [Float] :read_timeout Number of seconds to wait for one
      #   block of eAPI results to be read (via one read(2) call). Default
      #   is DEFAULT_HTTP_READ_TIMEOUT.
      def timeouts(opts = {})
        @open_timeout = opts.fetch(:open_timeout, DEFAULT_HTTP_OPEN_TIMEOUT)
        @read_timeout = opts.fetch(:read_timeout, DEFAULT_HTTP_READ_TIMEOUT)
      end

      ##
      # Generates the eAPI JSON request message.
      #
      # @example eAPI Request
      #   {
      #     "jsonrpc": "2.0",
      #     "method": "runCmds",
      #     "params": {
      #       "version": 1,
      #       "cmds": [
      #         <commands>
      #       ],
      #       "format": [json, text],
      #     }
      #     "id": <reqid>
      #   }
      #
      # @param [Array] :commands The ordered set of commands that should
      #   be included in the eAPI request
      # @param [Hash] :opts Optional keyword arguments
      # @option :opts [String] :id The value to use for the eAPI request
      #   id.  If not provided,the object_id for the connection instance
      #   will be used
      # @option :opts [String] :format The encoding formation to pass in
      #   the eAPI request.  Valid values are json or text.  The default
      #   value is json
      #
      # @return [Hash] Returns a Ruby hash of the request message that is
      #   suitable to be JSON encoded and sent to the destination node
      def request(commands, opts = {})
        id = opts.fetch(:reqid, object_id)
        format = opts.fetch(:format, 'json')
        cmds = [*commands]
        params = { 'version' => 1, 'cmds' => cmds, 'format' => format }
        { 'jsonrpc' => '2.0', 'method' => 'runCmds',
          'params' => params, 'id' => id }
      end

      ##
      # This method will send the request to the node over the specified
      # transport and return a response message with the contents from
      # the eAPI response.  eAPI responds to request messages with either
      # a success message or failure message.
      #
      # @example eAPI Response - success
      #   {
      #     "jsonrpc": "2.0",
      #     "result": [
      #       {},
      #       {},
      #       {
      #         "warnings": [
      #           <message>
      #         ]
      #       },
      #     ],
      #     "id": <reqid>
      #   }
      #
      # @example eAPI Response - failure
      #   {
      #     "jsonrpc": "2.0",
      #     "error": {
      #       "code": <int>,
      #       "message": <string>,
      #       "data": [
      #         {},
      #         {},
      #         {
      #           "errors": [
      #             <message>
      #           ]
      #         }
      #       ]
      #     },
      #     "id": <reqid>
      #   }
      #
      # @param [Hash] :data A hash containing the body of the request
      #   message.  This should be a valid eAPI request message.
      # @option :opts [Float] :open_timeout Number of seconds to wait for the
      #   eAPI connection to open.
      # @option :opts [Float] :read_timeout Number of seconds to wait for one
      #   block of eAPI results to be read (via one read(2) call).
      #
      # @return [Hash] returns the response message as a Ruby hash object
      #
      # @raises [CommandError] Raised if an eAPI failure response is return
      #   from the destination node.
      def send(data, opts)
        request = Net::HTTP::Post.new('/command-api')
        request.body = JSON.dump(data)
        request.basic_auth @username, @password

        open_timeout = opts.fetch(:open_timeout, @open_timeout)
        read_timeout = opts.fetch(:read_timeout, @read_timeout)

        begin
          @transport.open_timeout = open_timeout
          @transport.read_timeout = read_timeout
          response = @transport.request(request)
          decoded = JSON(response.body)

          if decoded.include?('error')
            code = decoded['error']['code']
            msg = decoded['error']['message']
            fail CommandError.new(msg, code)
          end
        rescue Timeout::Error
          raise ConnectionError, 'unable to connect to eAPI'
        end

        decoded
      end

      ##
      # Executes the commands on the destination node and returns the
      # response from the node.
      #
      # @param [Array] :commands The ordered list of commands to execute
      #   on the destination node.
      # @param [Hash] :opts Optional keyword arguments
      # @option :opts [String] :encoding Used to specify the encoding to be
      #   used for the response.  Valid encoding values are json or text
      # @option :opts [Float] :open_timeout Number of seconds to wait for the
      #   eAPI connection to open.
      # @option :opts [Float] :read_timeout Number of seconds to wait for one
      #   block of eAPI results to be read (via one read(2) call).
      #
      # @returns [Array<Hash>] This method will return the array of responses
      #   for each command executed on the node.
      #
      # @raises [CommandError] Raises a CommandError if rescued from the
      #   send method and adds the list of commands to the exception message
      #
      # @raises [ConnectionError] Raises a ConnectionError if rescued and
      #   adds the list of commands to the exception message
      def execute(commands, opts = {})
        @error = nil
        request = request(commands, opts)
        response = send(request, opts)
        return response['result']
      rescue ConnectionError, CommandError => exc
        exc.commands = commands
        @error = exc
        raise
      end
    end

    ##
    # The SocketEapiConnection provides a class for building a domain
    # socket eAPI connection to Arista EOS devices.
    class SocketEapiConnection < EapiConnection
      def initialize(opts = {})
        path = opts.fetch(:path, DEFAULT_UNIX_SOCKET)
        transport = NetX::HTTPUnix.new("unix://#{path}")
        super(transport)
      end
    end

    ##
    # The HttpEapiConnection provides a class for building an HTTP
    # eAPI connection to a Arista EOS devices.
    class HttpEapiConnection < EapiConnection
      def initialize(opts = {})
        port = opts.fetch(:port, DEFAULT_HTTP_PORT)
        host = opts.fetch(:host, 'localhost')

        transport = Net::HTTP.new(host, port.to_i)
        super(transport)

        authentication(opts)
        timeouts(opts)
      end
    end

    ##
    # The HttpLocalEapiConnection provides a class for building an HTTP
    # eAPI connection to a local Arista EOS devices.
    class HttpLocalEapiConnection < EapiConnection
      def initialize(opts = {})
        port = opts.fetch(:port, DEFAULT_HTTP_LOCAL_PORT)
        transport = Net::HTTP.new('localhost', port)
        super(transport)

        authentication(opts)
        timeouts(opts)
      end
    end

    ##
    # The HttpEapiConnection provides a class for building an HTTPS
    # eAPI connection to a Arista EOS devices.
    class HttpsEapiConnection < EapiConnection
      def initialize(opts = {})
        host = opts.fetch(:host, 'localhost')
        port = opts.fetch(:port, DEFAULT_HTTPS_PORT)

        transport = Net::HTTP.new(host, port)
        transport.use_ssl = true
        transport.verify_mode = OpenSSL::SSL::VERIFY_NONE
        super(transport)

        authentication(opts)
        timeouts(opts)
      end
    end
  end
end
