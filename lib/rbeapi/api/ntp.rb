#
# Copyright (c) 2014,2015, Arista Networks, Inc.
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
require 'rbeapi/api'

##
# Rbeapi toplevel namespace.
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The Ntp class provides an instance for working with the nodes
    # NTP configuration.
    class Ntp < Entity
      DEFAULT_TRST_KEY = ''.freeze
      DEFAULT_SRC_INTF = ''.freeze

      # Regular expression to extract a NTP server's attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrapping and indentation with the /x flag.

      SERVER_REGEXP = /^(?:ntp[ ]server)
                      (?:(?:[ ]vrf[ ])([^\s]+))?
                      [ ]([^\s]+)
                      ([ ]prefer)?
                      (?:(?:[ ]minpoll[ ])(\d+))?
                      (?:(?:[ ]maxpoll[ ])(\d+))?
                      (?:(?:[ ]source[ ])([^\s]+))?
                      (?:(?:[ ]key[ ])(\d+))?/x
      ##

      # Regular expression to extract NTP authentication-keys from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrapping and indentation with the /x flag.

      AUTH_KEY_REGEXP = /^(?:ntp[ ]authentication-key[ ])
                        (\d+)[ ](\w+)[ ](\d+)[ ](\w+)/x
      ##
      # get returns the nodes current ntp configure as a resource hash.
      #
      # @example
      #   {
      #     authenticate: [true, false],
      #     source_interface: <string>,
      #     servers: {
      #       prefer: [true, false]
      #     }
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] Returns the ntp resource as a
      #   Hash.
      def get
        response = {}
        response.merge!(parse_authenticate)
        response.merge!(parse_source_interface)
        response.merge!(parse_servers)
        response.merge!(parse_trusted_key)
        response.merge!(parse_auth_keys)
        response
      end

      ##
      # parse_authenticate checks to see if NTP authencation is enabled in conf
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_authenticate
        mdata = /^(?:ntp authenticate)/.match(config)
        { authenticate: mdata.nil? ? false : true }
      end
      private :parse_authenticate

      ##
      # parse_auth_keys scans the nodes configuration and parses the configured
      # authencation keys. This method will also return
      # the value of prefer. If no keys are configured, the value will be
      # set to an empty array. The return hash is intended to be merged into
      # the resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_auth_keys
        tuples = config.scan(AUTH_KEY_REGEXP)
        hsh = {}
        tuples.map do |(key, algorithm, mode, password)|
          hsh[key] = {
            algorithm: algorithm,
            mode: mode,
            password: password
          }
          hsh[key]
        end

        { auth_keys: hsh }
      end
      private :parse_auth_keys

      ##
      # parse_source_interface scans the nodes configurations and parses
      # the ntp source interface if configured. If the source interface
      # is not configured, this method will return DEFAULT_SRC_INTF as the
      # value. The return hash is intended to be merged into the resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_source_interface
        mdata = /(?<=^ntp\ssource\s)(.+)$/.match(config)
        { source_interface: mdata.nil? ? DEFAULT_SRC_INTF : mdata[1] }
      end
      private :parse_source_interface

      ##
      # parse_servers scans the nodes configuration and parses the configured
      # ntp server host names and/or addresses. This method will also return
      # the value of prefer. If no servers are configured, the value will be
      # set to an empty array. The return hash is intended to be merged into
      # the resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_servers
        tuples = config.scan(SERVER_REGEXP)
        hsh = {}
        tuples.map do |(vrf, host, prefer, minpoll, maxpoll, sourcei, key)|
          hsh[host] = {
            vrf: vrf,
            prefer: !prefer.nil?,
            minpoll: minpoll.nil? ? nil : minpoll.to_i,
            maxpoll: maxpoll.nil? ? nil : maxpoll.to_i,
            source_interface: sourcei,
            key: key.nil? ? nil : key.to_i
          }
          hsh[host]
        end

        { servers: hsh }
      end
      private :parse_servers

      ##
      # parse_trusted_key looks for global NTP trusted-key list
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_trusted_key
        mdata = /^(?:ntp trusted-key (.+))/.match(config)
        { trusted_key: mdata.nil? ? DEFAULT_TRST_KEY : mdata[1] }
      end
      private :parse_trusted_key

      ##
      # set_authenticate configures ntp authentication in the nodes
      # running configuration. If the enable keyword is false, then
      # ntp authentication is configured with the no keyword argument. If the
      # default keyword argument is provided and set to true, the value is
      # configured used the default keyword. The default keyword takes
      # precedence over the enable keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ntp authenticate
      #   no ntp authenticate
      #   default ntp authenticate
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ntp source value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_authenticate(opts = {})
        cmd = command_builder('ntp authenticate', opts)
        configure(cmd)
      end

      ##
      # set_authentication_key configures the ntp authentication-keys in the
      # device running configuration. If the enable keyword is false, then
      # the ntp source is configured with the no keyword argument. If the
      # default keyword argument is provided and set to true, the value is
      # configured used the default keyword. The default keyword takes
      # precedence over the enable keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ntp trusted-key <key> <algorithm> <mode> <password>
      #   no ntp trusted-key <key>
      #   default ntp trusted-key <key>
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts algorithm [String] Encryption algorithm to use, md5/sha1
      #
      # @option opts default [Boolean] Configure the ntp source value using
      #   the default keyword.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts key [Integer] The authentication-key to configure
      #
      # @option opts mode [Integer] Password mode: 0 plain-text, 7 encrypted
      # default value is 7
      #
      # @option opts password [String] Password to use for authentication-key
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_authentication_key(opts = {})
        cmd = command_builder('ntp authentication-key', opts)
        configure(cmd)

        algorithm = opts[:algorithm]
        default = opts[:default] || false
        enable = opts.fetch(:enable, true)
        key = opts[:key]
        mode = opts.fetch(:mode, 7)
        password = opts[:password]

        case default
        when true
          cmds = "default ntp authentication-key #{key}"
        when false
          cmds = if enable
                   "ntp authentication-key #{key} #{algorithm} #{mode} "\
                   "#{password}"
                 else
                   "no ntp authentication-key #{key}"
                 end
        end
        configure cmds
      end

      ##
      # set_source_interface configures the ntp source value in the nodes
      # running configuration. If the enable keyword is false, then
      # the ntp source is configured with the no keyword argument. If the
      # default keyword argument is provided and set to true, the value is
      # configured used the default keyword. The default keyword takes
      # precedence over the enable keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ntp source <value>
      #   no ntp source
      #   default ntp source
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] The value to configure the ntp source
      #   in the nodes configuration.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ntp source value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_source_interface(opts = {})
        cmd = command_builder('ntp source', opts)
        configure(cmd)
      end

      ##
      # set_trusted_key configures the ntp trusted-keys in the device
      # running configuration. If the enable keyword is false, then
      # the ntp authentication-key is configured with the no keyword argument.
      # If the default keyword argument is provided and set to true, the value
      # is configured using the default keyword. The default keyword takes
      # precedence over the enable keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ntp authentication-key <key> <algorithm> <mode> <password>
      #   no ntp authentication-key <key>
      #   default ntp trusted-key <key>
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [Integer] authentication-key id
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ntp source value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_trusted_key(opts = {})
        cmd = command_builder('ntp trusted-key', opts)
        configure(cmd)
      end

      ##
      # add_server configures a new ntp server destination hostname or ip
      # address to the list of ntp destinations. The optional prefer argument
      # configures the server as a preferred (true) or not (false) ntp
      # destination.
      #
      # @param server [String] The IP address or FQDN of the NTP server to
      #   be removed from the configuration.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @param opts vrf [String] The VRF instance this server is bound to
      #
      # @param opts minpoll [Integer] The minimum poll interval
      #
      # @param opts maxpoll [Integer] The maximum poll interval
      #
      # @param opts source [String] The source interface used to reach server
      #
      # @param opts key [Integer] The authentication key used to communicate
      #   with server
      #
      # @param prefer [Boolean] Appends the prefer keyword argument to the
      #   command if this value is true.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def add_server(server, prefer = false, opts = {})
        cmd = 'ntp server '
        cmd << "vrf #{opts[:vrf]} " if opts[:vrf]
        cmd << server.to_s
        cmd << ' prefer' if prefer || opts[:prefer].to_s == 'true'
        cmd << " minpoll #{opts[:minpoll]} " if opts[:minpoll]
        cmd << " maxpoll #{opts[:maxpoll]} " if opts[:maxpoll]
        cmd << " source #{opts[:source_interface]} " if opts[:source_interface]
        cmd << " key #{opts[:key]} " if opts[:key]
        configure(cmd)
      end

      ##
      # remove_server deletes the provided server destination from the list of
      # ntp server destinations. If the ntp server does not exist in the list
      # of servers, this method will return successful
      #
      # @param server [String] The IP address or FQDN of the NTP server to
      #   be removed from the configuration.
      #
      # @param vrf [String] The VRF of the NTP server to be removed from
      #   the configuration.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def remove_server(server, vrf = nil)
        configure("no ntp server #{vrf.nil? ? '' : "vrf #{vrf} "}#{server}")
      end

      ##
      # set_prefer will set the prefer keyword for the specified ntp server.
      # If the server does not already exist in the configuration, it will be
      # added and the prefer keyword will be set.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ntp server <srv> prefer
      #   no ntp server <srv> prefer
      #
      # @param srv [String] The IP address or hostname of the ntp server to
      #   configure with the prefer value.
      #
      # @param value [Boolean] The value to configure for prefer.  If true
      #   the prefer value is configured for the server.  If false, then the
      #   prefer value is removed.
      #
      # @return [Boolean] Returns true if the commands completed successfully.
      def set_prefer(srv, value)
        case value
        when true
          cmds = "ntp server #{srv} prefer"
        when false
          cmds = ["no ntp server #{srv} prefer", "ntp server #{srv}"]
        end
        configure cmds
      end
    end
  end
end
