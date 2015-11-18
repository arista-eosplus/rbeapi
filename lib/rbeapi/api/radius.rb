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
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::Api
  module Api
    ##
    # Radius provides instance methods to retrieve and set radius configuration
    # values.
    class Radius < Entity
      DEFAULT_KEY_FORMAT = 0
      DEFAULT_KEY = nil

      # Regular expression to extract a radius server's attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrapping and indentation with the /x flag.
      SERVER_REGEXP = /radius-server[ ]host[ ](.*?)
                       (?:[ ]vrf[ ]([^\s]+))?
                       (?:[ ]auth-port[ ](\d+))?
                       (?:[ ]acct-port[ ](\d+))?
                       (?:[ ]timeout[ ](\d+))?
                       (?:[ ]retransmit[ ](\d+))?
                       (?:[ ]key[ ](\d+)[ ](\w+))?\s/x

      ##
      # get Returns an Array with a single resource Hash describing the
      # current state of the global radius configuration on the target device.
      # This method is intended to be used by a provider's instances class
      # method.
      #
      # The resource hash returned contains the following information:
      #  * key: (String) the key either in plain text or hashed format
      #  * key_format: (Fixnum) e.g. 0 or 7
      #  * timeout: (Fixnum) seconds before the timeout period ends
      #  * retransmit: (Fixnum), e.g. 3, attempts after first timeout expiry.
      #  * servers: (Array),
      #
      # @api public
      #
      # @return [Array<Hash>] Single element Array of resource hashes
      def get
        global = {}
        global.merge!(parse_global_timeout)
        global.merge!(parse_global_retransmit)
        global.merge!(parse_global_key)
        resource = { global: global, servers: parse_servers }
        resource
      end

      ##
      # parse_time scans the nodes current configuration and parse the
      # radius-server timeout value.  The timeout value is expected to always
      # be present in the config
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_global_timeout
        value = config.scan(/radius-server timeout (\d+)/).first
        { timeout: value.first.to_i }
      end
      private :parse_global_timeout

      ##
      # parse_retransmit scans the cnodes current configuration and parses the
      # radius-server retransmit value.  the retransmit value is expected to
      # always be present in the config
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_global_retransmit
        value = config.scan(/radius-server retransmit (\d+)/).first
        { retransmit: value.first.to_i }
      end
      private :parse_global_retransmit

      ##
      # parse_key scans the current nodes running configuration and parse the
      # global radius-server key and format value.  If the key is not
      # configured this method will return DEFAULT_KEY and DEFAULT_KEY_FORMAT
      # for the resource hash values.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_global_key
        rsrc_hsh = {}
        (key_format, key) = config.scan(/radius-server key (\d+) (\w+)/).first
        rsrc_hsh[:key_format] = key_format.to_i || DEFAULT_KEY_FORMAT
        rsrc_hsh[:key] = key || DEFAULT_KEY
        rsrc_hsh
      end
      private :parse_global_key

      ##
      # parse_servers returns an Array of radius server resource hashes.  Each
      # hash describes the current state of the radius server and is intended
      # to be merged into the radius resource hash
      #
      # The resource hash returned contains the following information:
      #  * hostname: hostname or ip address
      #  * vrf: (String) vrf name
      #  * key: (String) the key either in plain text or hashed format
      #  * key_format: (Fixnum) e.g. 0 or 7
      #  * timeout: (Fixnum) seconds before the timeout period ends
      #  * retransmit: (Integer), e.g. 3, attempts after first timeout expiry.
      #  * group: (String) Server group associated with this server.
      #  * acct_port: (Fixnum) Port number to use for accounting.
      #  * accounting_only: (Boolean) Enable this server for accounting only.
      #  * auth_port: (Fixnum) Port number to use for authentication
      #
      # @api private
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes
      def parse_servers
        tuples = config.scan(SERVER_REGEXP)
        tuples.map do |(host, vrf, authp, acctp, tout, tries, keyfm, key)|
          hsh = {}
          hsh[:hostname]         = host
          hsh[:vrf]              = vrf
          hsh[:auth_port]        = authp.to_i
          hsh[:acct_port]        = acctp.to_i
          hsh[:timeout]          = tout.to_i
          hsh[:retransmit]       = tries.to_i
          hsh[:key_format]       = keyfm.to_i
          hsh[:key]              = key
          hsh
        end
      end
      private :parse_servers

      ##
      # set_global_key configures the global radius-server key.  If the enable
      # option is false, radius-server key is configured using the no
      # keyword. If the default option is specified, radius-server key is
      # configured using the default keyword. If both options are specified,
      # the default keyword option takes precedence.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   radius-server key <format> <value>
      #   no radius-server key
      #   default radius-server key
      #
      # @option [String] :value The value to configure the radius-server key to
      #   in the nodes running configuration
      #
      # @option [Fixnum] :key_format The format of the key to be passed to the
      #   nodes running configuration.  Valid values are 0 (clear text) or 7
      #   (encrypted).  The default value is 0 if format is not provided.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option [Boolean] :default Configures the radius-server key using the
      #   default keyword argument
      #
      # @return [Boolean] returns true if the commands complete successfully
      def set_global_key(opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        key_format = opts[:key_format] || 0
        default = opts[:default] || false

        case default
        when true
          cmds = 'default radius-server key'
        when false
          if enable
            cmds = "radius-server key #{key_format} #{value}"
          else
            cmds = 'no radius-server key'
          end
        end
        configure cmds
      end

      ##
      # set_global_timeout configures the radius-server timeout value.  If the
      # enable option is false, then radius-server timeout is configured
      # using the no keyword.  If the default option is specified, radius-server
      # timeout is configured using the default keyword.  If both options are
      # specified then the default keyword takes precedence.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   radius-server timeout <value>
      #   no radius-server timeout
      #   default radius-server timeout
      #
      # @option [String, Fixnum] :value The value to set the global
      #   radius-server timeout value to.  This value should be in the range of
      #   1 to 1000
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option [Boolean] :default Configures the radius-server timeout value
      #   using the default keyword.
      #
      # @return [Boolean] returns true if the commands complete successfully
      def set_global_timeout(opts = {})
        cmd = command_builder('radius-server timeout', opts)
        configure cmd
      end

      ##
      # set_global_retransmit configures the global radius-server retransmit
      # value. If the enable option  is false, then the radius-server retransmit
      # value is configured using the no keyword.  If the default option is
      # specified, the radius-server retransmit value is configured using the
      # default keyword. If both options are specified then the default keyword
      # takes precedence
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   radius-server retransmit <value>
      #   no radius-server retransmit
      #   default radius-server retransmit
      #
      # @option [String, Fixnum] :value The value to set the global
      #   radius-server retransmit value to.  This value should be in the range
      #   of 1 to 100
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option [Boolean] :default Configures the radius-server retransmit
      #   value using the default keyword
      #
      # @return [Boolean] returns true if the commands complete successfully
      def set_global_retransmit(opts = {})
        cmd = command_builder('radius-server retransmit', opts)
        configure cmd
      end

      ##
      # update_server configures a radius server resource on the target device.
      # This API method maps to the `radius server host` command, e.g.
      # `radius-server host 10.11.12.13 auth-port 1024 acct-port 2048 timeout
      # 30 retransmit 5 key 7 011204070A5955`
      #
      # @api public
      #
      # @return [Boolean] true if there are no errors
      def update_server(opts = {})
        # beware: order of cli keyword options counts
        key_format = opts[:key_format] || 7
        cmd = "radius-server host #{opts[:hostname]}"
        cmd << " vrf #{opts[:vrf]}"               if opts[:vrf]
        cmd << " auth-port #{opts[:auth_port]}"   if opts[:auth_port]
        cmd << " acct-port #{opts[:acct_port]}"   if opts[:acct_port]
        cmd << " timeout #{opts[:timeout]}"       if opts[:timeout]
        cmd << " retransmit #{opts[:retransmit]}" if opts[:retransmit]
        cmd << " key #{key_format} #{opts[:key]}" if opts[:key]
        configure cmd
      end

      ##
      # remove_server removes the SNMP server identified by the hostname,
      # auth_port, and acct_port attributes.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def remove_server(opts = {})
        cmd = "no radius-server host #{opts[:hostname]}"
        cmd << " vrf #{opts[:vrf]}"             if opts[:vrf]
        cmd << " auth-port #{opts[:auth_port]}" if opts[:auth_port]
        cmd << " acct-port #{opts[:acct_port]}" if opts[:acct_port]
        configure cmd
      end
    end
  end
end
