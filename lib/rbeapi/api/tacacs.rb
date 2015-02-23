#
# Copyright (c) 2014, Arista Networks, Inc.
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

module Rbeapi
  ##
  # Eos is module namesapce for working with the EOS command API
  module Api

    ##
    # Tacacs provides instance methods to retrieve and set tacacs configuration
    # values.
    class Tacacs < Entity
      # Regular expression to extract a tacacs server's attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrappping and indentation with the /x flag.
      SERVER_REGEXP = /tacacs-server[ ]host[ ](.*?)
                       (?:[ ](single-connection))?
                       (?:[ ]port[ ](\d+))?
                       (?:[ ]timeout[ ](\d+))?
                       (?:[ ]key[ ](\d+)[ ](\w+))?\s/x

      # Default Tacacs TCP port
      DEFAULT_PORT = 49

      # Regular expression to extract a tacacs server's attributes from the
      # running-configuration text.  The explicit [ ] spaces enable line
      # wrappping and indentation with the /x flag.
      SERVER_GROUP_REGEXP = /aaa group server tacacs[+]? (.*)/

      # FIXME Needs to be updated
      GROUP_MEMBER_REGEXP = /server[ ](.*?)
                             (?:[ ]vrf[ ]([^ ]+))?
                             (?:[ ]port[ ](\d+))?\s/x

      ##
      # getall Returns an Array with a single resource Hash describing the
      # current state of the global tacacs configuration on the target device.
      # This method is intended to be used by a provider's instances class
      # method.
      #
      # The resource hash returned contains the following information:
      #  * name: ('settings')
      #  * enable: (true | false) if tacacs functionality is enabled.  This is
      #    always true for EOS.
      #  * key: (String) the key either in plaintext or hashed format
      #  * key_format: (Integer) e.g. 0 or 7
      #  * timeout: (Integer) seconds before the timeout period ends
      #
      # @api public
      #
      # @return [Array<Hash>] Single element Array of resource hashes
      def getall
        rsrc_hsh = tacacs_global_defaults
        rsrc_hsh.merge!(parse_global_key(config))
        rsrc_hsh.merge!(parse_global_timeout(config))
        [rsrc_hsh]
      end

      ##
      # tacacs_global_defaults returns the default values for the tacacs_global
      # resource.  This is in a single method to keep the information in one
      # place.  If a value is explicitly configured to be the same as a default
      # value it will not show up in the running configuration and as a result
      # will not be parsed out by the parse instance methods.  This method
      # exposes the default values.
      #
      # @return [Array<Hash>] Single element Array of resource hashes
      def tacacs_global_defaults
        {
          name: 'settings',
          enable: true,
          timeout: 5,
        }
      end
      private :tacacs_global_defaults

      ##
      # parse_global_key takes a running configuration as a string and
      # parses out the radius global key and global key format if it exists in
      # the configuration.  An empty Hash is returned if there is no global key
      # configured.  The intent of the Hash is to be merged into a property
      # hash.
      #
      # @param [String] config The running configuration as a single string.
      #
      # @api private
      #
      # @return [Hash<Symbol,Object>] resource hash attributes
      def parse_global_key(config)
        rsrc_hsh = {}
        (key_format, key) = config.scan(/tacacs-server key (\d+) (\w+)/).first
        rsrc_hsh[:key_format] = key_format.to_i if key_format
        rsrc_hsh[:key] = key if key
        rsrc_hsh
      end
      private :parse_global_key

      ##
      # parse_global_timeout takes a running configuration as a string
      # and parses out the tacacs global timeout if it exists in the
      # configuration.  An empty Hash is returned if there is no global timeout
      # value configured.  The intent of the Hash is to be merged into a
      # property hash.
      #
      # @param [String] config The running configuration as a single string.
      #
      # @api private
      #
      # @return [Hash<Symbol,Object>] resource hash attributes
      def parse_global_timeout(config)
        rsrc_hsh = {}
        timeout = config.scan(/tacacs-server timeout (\d+)/).first
        # EOS default is 5 (does not show up in the running config)
        rsrc_hsh[:timeout] = timeout.first.to_i if timeout
        rsrc_hsh
      end
      private :parse_global_timeout

      ##
      # set_global_key configures the tacacs default key.  This method maps to
      # the `tacacs-server key` EOS configuration command, e.g. `tacacs-server
      # key 7 070E234F1F5B4A`.
      #
      # @option opts [String] :key ('070E234F1F5B4A') The key value
      #
      # @option opts [Fixnum] :key_format (7) The key format, 0 for plaintext
      #   and 7 for a hashed value.  7 will be assumed if this option is not
      #   provided.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def set_global_key(opts = {})
        format = opts[:key_format] || 7
        key = opts[:key]
        fail ArgumentError, 'key option is required' unless key
        result = api.config("tacacs-server key #{format} #{key}")
        result == [{}]
      end

      ##
      # set_timeout configures the tacacs default timeout.  This method maps to
      # the `tacacs-server timeout` setting.
      #
      # @option opts [Fixnum] :timeout (50) The timeout in seconds to
      #   configure.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def set_timeout(opts = {})
        timeout = opts[:timeout]
        fail ArgumentError, 'timeout option is required' unless timeout
        result = api.config("tacacs-server timeout #{timeout}")
        result == [{}]
      end

      ##
      # servers returns an Array of tacacs server resource hashes.  Each hash
      # describes the current state of the tacacs server and is suitable for
      # use in initializing a tacacs_server provider.
      #
      # The resource hash returned contains the following information:
      #
      #  * hostname: hostname or ip address, part of the identifier
      #  * port: (Fixnum) TCP port of the server, part of the identifier
      #  * key: (String) the key either in plaintext or hashed format
      #  * key_format: (Fixnum) e.g. 0 or 7
      #  * timeout: (Fixnum) seconds before the timeout period ends
      #  * multiplex: (Boolean) true when configured to make requests through a
      #    single connection
      #
      # @api public
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes
      def servers
        config = running_configuration
        tuples = config.scan(SERVER_REGEXP)
        tuples.map do |(host, mplex, port, tout, keyfm, key)|
          hsh = { port: DEFAULT_PORT }
          hsh[:hostname]         = host       if host
          hsh[:port]             = port.to_i  if port
          hsh[:timeout]          = tout.to_i  if tout
          hsh[:key_format]       = keyfm.to_i if keyfm
          hsh[:key]              = key        if key
          hsh[:multiplex]        = mplex ? true : false
          hsh
        end
      end

      ##
      # server_groups retrieves a list of tacacs server groups from the target
      # device.
      #
      # @api public
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes
      def server_groups
        config = running_configuration
        regexp = SERVER_GROUP_REGEXP
        tuples = config.scan(regexp)
        tuples.map do |(name)|
          { name: name, servers: parse_group_servers(config, name) }
        end
      end

      ##
      # parse_group_servers parses the list of servers associated with a tacacs
      # server group given a group name and a running configuration text.
      #
      # @param [String] config The running configuration text.
      #
      # @param [String] name The name of the server group to parse.
      #
      # @api private
      #
      # @return [Array<Hash<Symbol,Object>] Array of server attributes
      def parse_group_servers(config, name)
        regexp = /aaa group server tacacs[+] #{name}(.*?)!/m
        mdata = regexp.match(config)
        tuples = mdata[1].scan(GROUP_MEMBER_REGEXP)
        tuples.collect do |(hostname, vrf, port)|
          { hostname: hostname, port: port ? port.to_i : DEFAULT_PORT }
        end
      end

      ##
      # update_server_group updates a tacacs server group given an Array of
      # server attributes and the name of the server group.  The update happens
      # by first deleting the existing group if it exists then creating it
      # again with all of the specified servers.
      #
      # @param [String] name The name of the server group to update
      #
      # @param [Array<Hash<Symbol,Object>>] servers The array of servers to
      #   associate with the server group.  This hash should have at least the
      #   :hostname key.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def update_server_group(opts = {})
        cmd = "aaa group server tacacs+ #{opts[:name]}"
        api.config("no #{cmd}")
        cmds = [cmd]
        opts[:servers].each do |hsh|
          cmds << "server #{hsh[:hostname]} port #{hsh[:port] || DEFAULT_PORT}"
        end
        result = api.config(cmds)
        !result.find { |r| r != {} }
      end

      ##
      # remove_server_group removes a tacacs server group by name.  This API
      # call maps to the `no aaa group server tacacs <name>` command.
      #
      # @option opts [String] :name ('TAC-GR') The name of the tacacs server
      #   group to remove.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def remove_server_group(opts = {})
        result = api.config("no aaa group server tacacs+ #{opts[:name]}")
        result == [{}]
      end

      ##
      # update_server configures a tacacs server resource on the target device.
      # This API method maps to the `tacacs server host` command, e.g.
      # `tacacs-server host 1.2.3.4 single-connection port 4949 timeout 6 key 7
      # 06070D221D1C5A`
      #
      # @api public
      #
      # @return [Boolean] true if there are no errors
      def update_server(opts = {})
        key_format = opts[:key_format] || 7
        cmd = "tacacs-server host #{opts[:hostname]}"
        cmd << ' single-connection'               if opts[:multiplex]
        cmd << " port #{opts[:port]}"             if opts[:port]
        cmd << " timeout #{opts[:timeout]}"       if opts[:timeout]
        cmd << " key #{key_format} #{opts[:key]}" if opts[:key]
        result = api.config(cmd)
        result == [{}]
      end

      ##
      # remove_server removes the tacacs server identified by the hostname,
      # and port attributes.
      #
      # @api public
      #
      # @return [Boolean] true if no errors
      def remove_server(opts = {})
        cmd = "no tacacs-server host #{opts[:hostname]}"
        cmd << " port #{opts[:port]}" if opts[:port]
        result = api.config(cmd)
        result == [{}]
      end
    end
  end
end
