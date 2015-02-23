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

    class Aaa < Entity

      def get
        response = {}
        response[:groups] = groups.getall
        response
      end

      def groups
        return @groups if @groups
        @groups = AaaGroups.new node
        @groups
      end
    end


    class AaaGroups < Entity


      DEFAULT_RADIUS_AUTH_PORT = 1812
      DEFAULT_RADIUS_ACCT_PORT = 1813


      # Regular express that parses the radius servers from the aaa group
      # server radius configuration block
      RADIUS_GROUP_SERVER = /\s{3}server
                             [ ]([^\s]+)
                             [ ]auth-port[ ](\d+)
                             [ ]acct-port[ ](\d+)/x

      ##
      # get returns the aaa server group resource hash that describes the
      # current configuration for the specified server group name
      #
      # The resource hash returned contains the following:
      #   * type: (String) The server group type.  Valid values are either
      #   'tacacs' or 'radius'
      #   * servers: (Array) The set of servers associated with the group.
      #   Servers are returned as either IP address or host name
      #
      # @param [String] :name The server group name to return from the nodes
      #   current running configuration.  If the name is not configured a nil
      #   object is returned.
      #
      # @return [nil, Hash<Symbol, Object>] returns the resource hash for the
      #   specified name.  If the name does not exist, a nil object is returned
      def get(name)
        config = get_block("aaa group server (radius|tacacs) #{name}")
        return nil unless config
        response = {}
        response.merge!(parse_type(config))
        response.merge!(parse_servers(config))
        response
      end

      def getall
        cfg = config.scan(/aaa group server \w+ (.+)$/)
        cfg.each_with_object({}) do |name, hsh|
          values = get(name.first)
          hsh[name.first] = values if values
        end
      end

      ##
      # parse_type scans the specified configuration block and returns the
      # server group type as either 'tacacs' or 'radius'  The type value is
      # expected to always be present in the config.
      #
      # @api private
      #
      # @param [String] :config The aaa server group block configuration for the
      #   group name to parse
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_type(config)
        value = config.scan(/aaa group server (\w+)/).first
        { type: value.first }
      end
      private :parse_type

      ##
      # parse_servers scans the specified configuraiton block and returns the
      # list of servers configured for the group.  If there are no servers
      # configured for the group the servers value will return an empty array.
      #
      # @api private
      #
      # @param [String] :config The aaa server group block configuration for the
      #   group name to parse
      #
      # @param [String] :type The aaa server block type.  Valid values are
      #   either radius or tacacs.
      #
      # @note Current only type: radius is supported
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_servers(config, type = 'radius')
        if type == 'radius'
          regex = RADIUS_GROUP_SERVER
        end

        values = config.scan(regex).map do |(name, auth, acct)|
          {
            name: name,
            auth_port: auth || DEFAULT_RADIUS_AUTH_PORT,
            acct_port: acct || DEFAULT_RADIUS_ACCT_PORT
          }
        end
        { servers: values }
      end
      private :parse_servers

      ##
      # find_type is a utility method to find the type of aaa server group for
      # the specified name.  This method will scan the current running
      # configuration on the node and return the server group type as either
      # 'radius' or 'tacacs+'.  If the server group is not configured, then nil
      # will be returned.
      #
      # @api private
      #
      # @param [String] :name The aaa server group name to find in the config
      #   and return the type value for
      #
      # @return [nil, String] returns either the type name as 'radius' or
      #   'tacacs+' or nil if the server group is not configured.
      def find_type(name)
        mdata = /aaa group server (\w+) #{name}/.match(config)
        return mdata[1] if mdata
      end
      private :find_type

      ##
      # create adds a new aaa group server to the nodes current configuration.
      # If the specified name and type are already created then this method
      # will return successfully.  If the name is configured but the type is
      # different, this method will not return successfully (returns false).
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   aaa group server <type> <name>
      #
      # @param [String] :name The name of the aaa group server to create in the
      #   nodes running configuration
      #
      # @param [String] :type The type of aaa group server to create in the
      #   nodes running configuration.  Valid values include 'radius' or
      #   'tacacs+'
      #
      # @return [Boolean] returns true if the commands complete successfully
      def create(name, type)
        configure "aaa group server #{type} #{name}"
      end

      ##
      # delete removes a current aaa server group from the nodes current
      # configuration.  This method will automatically determine the server
      # group type based on the name.  If the name is not configured in the
      # nodes current configuration, this method will return successfully.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   no aaa group server [radius | tacacs+] <name>
      #
      # @param [String] :name The name of the aaa group server to create in the
      #   nodes running configuration
      #
      # @return [Boolean] returns true if the commands complete successfully
      def delete(name)
        type = find_type(name)
        return true unless type
        configure "no aaa group server #{type} #{name}"
      end

      ##
      # set_servers configures the set of servers for a specified aaa server
      # group.  This is an atomic operation that first removes all current
      # servers and then adds the new servers back.  If any of the servers
      # failes to be removed or added, this method will return unsuccessfully.
      #
      # @see remove_server
      # @see add_server
      #
      # @param [String] :name The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param [String] :server The IP address or host name of the server to
      #   add to the configuration
      #
      # @param [Hash] :opts Optional configuration parameters
      #
      # @return [Boolean] returns true if the commands complete successfully
      def set_servers(name, servers)
        current = get(name)
        current[:servers].each do |srv|
          return false unless remove_server(name, srv)
        end
        servers.each do |srv|
          hostname = srv[:name]
          return false unless add_server(name, hostname, srv)
        end
        return true
      end

      ##
      # add_server adds a new server to the specified aaa server group.  If
      # the server is already configured in the list of servers, this method
      # will still return successfully.
      #
      # @see add_radius_server
      # @see add_tacacs_server
      #
      # @param [String] :name The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param [String] :server The IP address or host name of the server to
      #   add to the configuration
      #
      # @param [Hash] :opts Optional configuration parameters
      #
      # @return [Boolean] returns true if the commands complete successfully
      def add_server(name, server, opts = {})
        type = find_type(name)
        return false unless type
        case type
        when 'radius' then add_radius_server(name, server, opts)
        #when 'tacacs+' then add_tacacs_server(name, server, opts)
        end
      end

      ##
      # add_radius_server adds a new radius server to the nodes current
      # configuration.  If the server already exists in the specified group
      # name this method will still return successfully
      #
      # @eos_version 4.13.7M
      #
      # @commmands
      #   aaa group server radius <name>
      #   server <server> [acct-port <acct_port>] [auth-port <auth_port>]
      #                   [vrf <vrf>]
      #
      # @param [String] :name The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param [String] :server The IP address or host name of the server to
      #   add to the configuration
      #
      # @param [Hash] :opts Optional configuration parameters
      #
      # @return [Boolean] returns true if the commands complete successfully
      def add_radius_server(name, server, opts = {})
        # order of command options matter here!
        server = "server #{server} "
        server << "auth-port #{opts[:auth_port]} " if opts[:auth_port]
        server << "acct-port #{opts[:acct_port]} " if opts[:acct_port]
        server << "vrf #{opts[:vrf]}" if opts[:vrf]
        configure ["aaa group server radius #{name}", server, "exit"]
      end

      ##
      # remove_server deletes an existing server from the specified aaa server
      # group.  If the specified server is not configured in the specified
      # server group, this method will still return true.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   aaa group server [radius | tacacs+] <name>
      #   no server <server>
      #
      # @param [String] :name The name of the aaa group server to remove
      #
      # @param [String] :server The IP address or host name of the server
      #
      # @return [Boolean] returns true if the commands complete successfully
      def remove_server(name, server)
        type = find_type(name)
        return false unless type
        configure ["aaa group server #{type} #{name}", "no server #{server}",
                   "exit"]
      end
    end
  end
end
