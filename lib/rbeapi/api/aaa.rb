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

##
# Rbeapi toplevel namespace.
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The Aaa class manages Authorization, Authentication and Accounting (AAA)
    # on an EOS node.
    class Aaa < Entity
      ##
      # get returns a hash of all Aaa resources.
      #
      # @example
      #   {
      #     <groups>: {
      #       <name>: {
      #         type: <string>,
      #         servers: <array>
      #       },
      #       <name>: {
      #         type: <string>,
      #         servers: <array>
      #       }
      #     }
      #   }
      #
      # @return [Hash<Symbol, Object>] Returns the Aaa resources as a
      #   Hash. If no Aaa resources are found, an empty hash is returned.
      def get
        response = {}
        response[:groups] = groups.getall
        response
      end

      ##
      # Returns an object node for working with AaaGroups class.
      def groups
        return @groups if @groups
        @groups = AaaGroups.new node
        @groups
      end
    end

    ##
    # The AaaGroups class manages the server groups on an EOS node.
    class AaaGroups < Entity
      DEFAULT_RADIUS_AUTH_PORT = 1812
      DEFAULT_RADIUS_ACCT_PORT = 1813

      # Regular expression that parses the radius servers from the aaa group
      # server radius configuration block.
      RADIUS_GROUP_SERVER = /\s{3}server
                             [ ]([^\s]+)
                             [ ]auth-port[ ](\d+)
                             [ ]acct-port[ ](\d+)/x

      # Regular expression that parses the tacacs servers from the aaa group
      # server tacacs+ configuration block.
      TACACS_GROUP_SERVER = /\s{3}server
                             [ ]([^\s]+)
                             (?:[ ]vrf[ ](\w+))?
                             (?:[ ]port[ ](\d+))?/x

      ##
      # get returns the aaa server group resource hash that describes the
      # current configuration for the specified server group name.
      #
      # @example
      #   {
      #     type: <string>,
      #     servers: <array>
      #   }
      #
      # @param name [String] The server group name to return from the nodes
      #   current running configuration. If the name is not configured a nil
      #   object is returned.
      #
      # @return [nil, Hash<Symbol, Object>] Returns the resource hash for the
      #   specified name. If the name does not exist, a nil object is returned.
      def get(name)
        block = get_block("aaa group server ([^\s]+) #{name}")
        return nil unless block
        response = {}
        response.merge!(parse_type(block))
        response.merge!(parse_servers(block, response[:type]))
        response
      end

      ##
      # getall returns a aaa server groups hash.
      #
      # @example
      #   {
      #     <name>: {
      #       type: <string>,
      #       servers: <array>
      #     },
      #     <name>: {
      #       type: <string>,
      #       servers: <array>
      #     }
      #   }
      #
      # @return [Hash<Symbol, Object>] Returns the resource hashes for
      #   configured aaa groups. If none exist, a nil object is returned.
      def getall
        cfg = config.scan(/aaa group server (?:radius|tacacs\+) (.+)$/)
        cfg.each_with_object({}) do |name, hsh|
          values = get(name.first)
          hsh[name.first] = values if values
        end
      end

      ##
      # parse_type scans the specified configuration block and returns the
      # server group type as either 'tacacs' or 'radius'. The type value is
      # expected to always be present in the config.
      #
      # @api private
      #
      # @param config [String] The aaa server group block configuration for the
      #   group name to parse.
      #
      # @return [Hash<Symbol, Object>] Resource hash attribute.
      def parse_type(config)
        value = config.scan(/aaa group server ([^\s]+)/).first
        { type: value.first }
      end
      private :parse_type

      ##
      # parse_servers scans the specified configuraiton block and returns the
      # list of servers configured for the group. If there are no servers
      # configured for the group the servers value will return an empty array.
      #
      # @api private
      #
      # @see parse_radius_server
      # @see parse_tacacs_server
      #
      # @param config [String] The aaa server group block configuration for the
      #   group name to parse.
      #
      # @param type [String] The aaa server block type. Valid values are
      #   either radius or tacacs+.
      #
      # @return [Hash<Symbol, Object>] Resource hash attribute
      def parse_servers(config, type)
        case type
        when 'radius' then parse_radius_server(config)
        when 'tacacs+' then parse_tacacs_server(config)
        end
      end
      private :parse_servers

      ##
      # parse_radius_server scans the provide configuration block and returns
      # the list of servers configured. The configuration block is expected to
      # be a radius configuration block. If there are no servers configured
      # for the group the servers value will return an empty array.
      #
      # @api private
      #
      # @param config [String] The aaa server group block configuration for the
      #   group name to parse
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_radius_server(config)
        values = config.scan(RADIUS_GROUP_SERVER).map do |(name, auth, acct)|
          {
            name: name,
            auth_port: auth || DEFAULT_RADIUS_AUTH_PORT,
            acct_port: acct || DEFAULT_RADIUS_ACCT_PORT
          }
        end
        { servers: values }
      end
      private :parse_radius_server

      ##
      # parse_tacacs_server scans the provided configuration block and returns
      # the list of configured servers. The configuration block is expected to
      # be a tacacs configuration block. If there are no servers configured
      # for the group the servers value will return an empty array.
      #
      # @api private
      #
      # @param config [String] The aaa server group block configuration for the
      #   group name to parse.
      #
      # @return [Hash<Symbol, Object>] Resource hash attribute.
      def parse_tacacs_server(config)
        values = config.scan(TACACS_GROUP_SERVER).map do |(name, vrf, port)|
          {
            name: name,
            vrf: vrf,
            port: port
          }
        end
        { servers: values }
      end
      private :parse_radius_server

      ##
      # find_type is a utility method to find the type of aaa server group for
      # the specified name. This method will scan the current running
      # configuration on the node and return the server group type as either
      # 'radius' or 'tacacs+'. If the server group is not configured, then nil
      # will be returned.
      #
      # @api private
      #
      # @param name [String] The aaa server group name to find in the config
      #   and return the type value for.
      #
      # @return [nil, String] Returns either the type name as 'radius' or
      #   'tacacs+' or nil if the server group is not configured.
      def find_type(name)
        mdata = /aaa group server ([^\s]+) #{name}/.match(config)
        return mdata[1] if mdata
      end
      private :find_type

      ##
      # create adds a new aaa group server to the nodes current configuration.
      # If the specified name and type are already created then this method
      # will return successfully. If the name is configured but the type is
      # different, this method will not return successfully (returns false).
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   aaa group server <type> <name>
      #
      # @param name [String] The name of the aaa group server to create in the
      #   nodes running configuration
      #
      # @param type [String] The type of aaa group server to create in the
      #   nodes running configuration. Valid values include 'radius' or
      #   'tacacs+'
      #
      # @return [Boolean] returns true if the commands complete successfully
      def create(name, type)
        configure ["aaa group server #{type} #{name}", 'exit']
      end

      ##
      # delete removes a current aaa server group from the nodes current
      # configuration. This method will automatically determine the server
      # group type based on the name. If the name is not configured in the
      # nodes current configuration, this method will return successfully.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   no aaa group server [radius | tacacs+] <name>
      #
      # @param name [String] The name of the aaa group server to create in the
      #   nodes running configuration.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def delete(name)
        type = find_type(name)
        return true unless type
        configure "no aaa group server #{type} #{name}"
      end

      ##
      # set_servers configures the set of servers for a specified aaa server
      # group. This is an atomic operation that first removes all current
      # servers and then adds the new servers back. If any of the servers
      # failes to be removed or added, this method will return unsuccessfully.
      #
      # @see remove_server
      # @see add_server
      #
      # @param name [String] The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param servers [String] The IP address or host name of the server to
      #   add to the configuration
      #
      # @return [Boolean] Returns true if the commands complete successfully
      def set_servers(name, servers)
        current = get(name)
        current[:servers].each do |srv|
          return false unless remove_server(name, srv)
        end
        servers.each do |srv|
          hostname = srv[:name]
          return false unless add_server(name, hostname, srv)
        end
        true
      end

      ##
      # add_server adds a new server to the specified aaa server group. If
      # the server is already configured in the list of servers, this method
      # will still return successfully.
      #
      # @see add_radius_server
      # @see add_tacacs_server
      #
      # @param name [String] The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param server [String] The IP address or host name of the server to
      #   add to the configuration.
      #
      # @param opts [Hash] Optional configuration parameters.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def add_server(name, server, opts = {})
        type = find_type(name)
        return false unless type
        case type
        when 'radius' then add_radius_server(name, server, opts)
        when 'tacacs+' then add_tacacs_server(name, server, opts)
        else return false
        end
      end

      ##
      # add_radius_server adds a new radius server to the nodes current
      # configuration.  If the server already exists in the specified group
      # name this method will still return successfully.
      #
      # @since eos_version 4.13.7M
      #
      # commmands
      #   aaa group server radius <name>
      #   server <server> [acct-port <acct_port>] [auth-port <auth_port>]
      #                   [vrf <vrf>]
      #
      # @param name [String] The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param server [String] The IP address or host name of the server to
      #   add to the configuration.
      #
      # @param opts [Hash] Optional configuration parameters.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def add_radius_server(name, server, opts = {})
        # order of command options matter here!
        server = "server #{server} "
        server << "auth-port #{opts[:auth_port]} " if opts[:auth_port]
        server << "acct-port #{opts[:acct_port]} " if opts[:acct_port]
        server << "vrf #{opts[:vrf]}" if opts[:vrf]
        configure ["aaa group server radius #{name}", server, 'exit']
      end

      ##
      # add_tacacs_server adds a new tacacs server to the nodes current
      # configuration. If the server already exists in the specified group
      # name this method will still return successfully.
      #
      # @since eos_version 4.13.7M
      #
      # commmands
      #   aaa group server tacacs+ <name>
      #   server <server> [acct-port <acct_port>] [auth-port <auth_port>]
      #                   [vrf <vrf>]
      #
      # @param name [String] The name of the aaa group server to add the new
      #   server configuration to.
      #
      # @param server [String] The IP address or host name of the server to
      #   add to the configuration.
      #
      # @param opts [Hash] Optional configuration parameters.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def add_tacacs_server(name, server, opts = {})
        # order of command options matter here!
        server = "server #{server} "
        server << "vrf #{opts[:vrf]} "    if opts[:vrf]
        server << "port #{opts[:port]} "  if opts[:port]
        configure ["aaa group server tacacs+ #{name}", server, 'exit']
      end

      ##
      # remove_server deletes an existing server from the specified aaa server
      # group. If the specified server is not configured in the specified
      # server group, this method will still return true.
      #
      # eos_version 4.13.7M
      #
      # ===Commands
      #   aaa group server [radius | tacacs+] <name>
      #   no server <server>
      #
      # @param name [String] The name of the aaa group server to remove.
      #
      # @param server [String] The IP address or host name of the server.
      #
      # @param opts [Hash] Optional configuration parameters.
      #
      # @return [Boolean] returns true if the commands complete successfully.
      def remove_server(name, server, opts = {})
        type = find_type(name)
        return false unless type
        server = "no server #{server} "
        server << "vrf #{opts[:vrf]}" if opts[:vrf]
        configure ["aaa group server #{type} #{name}", server, 'exit']
      end
    end
  end
end
