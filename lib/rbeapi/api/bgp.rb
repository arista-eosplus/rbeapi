#
# Copyright (c) 2015, Arista Networks, Inc.
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
# Eos is the toplevel namespace for working with Arista EOS nodes.
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The Bgp class implements global BGP router configuration.
    class Bgp < Entity
      attr_reader :neighbors

      def initialize(node)
        super(node)
        @neighbors = BgpNeighbors.new(node)
      end

      ##
      # get returns the BGP routing configuration from the nodes current
      # configuration.
      #
      # @example
      #   {
      #     bgp_as: <string>,
      #     router_id: <string>,
      #     shutdown: <string>,
      #     maximum_paths: <integer>,
      #     maximum_ecmp_paths: <integer>
      #     networks: [
      #       {
      #         prefix: <string>,
      #         masklen: <integer>,
      #         route_map: <string>
      #       },
      #       {
      #         prefix: <string>,
      #         masklen: <integer>,
      #         route_map: <string>
      #       }
      #     ],
      #     neighbors: {
      #       name: {
      #         peer_group: <string>,
      #         remote_as: <string>,
      #         send_community: <boolean>,
      #         shutdown: <boolean>,
      #         description: <string>,
      #         next_hop_selp: <boolean>,
      #         route_map_in: <string>,
      #         route_map_out: <string>
      #       },
      #       name: {
      #         peer_group: <string>,
      #         remote_as: <string>,
      #         send_community: <boolean>,
      #         shutdown: <boolean>,
      #         description: <string>,
      #         next_hop_selp: <boolean>,
      #         route_map_in: <string>,
      #         route_map_out: <string>
      #       },
      #       ...
      #     }
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] Returns the BGP resource as a
      #   Hash.
      def get
        config = get_block('^router bgp .*')
        return nil unless config

        response = Bgp.parse_bgp_as(config)
        response.merge!(parse_router_id(config))
        response.merge!(parse_shutdown(config))
        response.merge!(parse_maximum_paths(config))
        response.merge!(parse_networks(config))
        response[:neighbors] = @neighbors.getall
        response
      end

      ##
      # parse_bgp_as scans the BGP routing configuration for the
      # AS number. Defined as a class method. Used by the BgpNeighbors
      # class below.
      #
      # @param config [String] The switch config.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def self.parse_bgp_as(config)
        value = config.scan(/^router bgp (\d+)/).first
        { bgp_as: value[0] }
      end

      ##
      # parse_router_id scans the BGP routing configuration for the
      # router ID.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_router_id(config)
        value = config.scan(/router-id ([^\s]+)/).first
        value = value ? value[0] : nil
        { router_id: value }
      end
      private :parse_router_id

      ##
      # parse_shutdown scans the BGP routing configuration for the
      # shutdown status.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute. Returns
      # true if shutdown, false otherwise.
      def parse_shutdown(config)
        value = config.include?('no shutdown')
        { shutdown: !value }
      end
      private :parse_shutdown

      ##
      # parse_maximum_paths scans the BGP routing configuration for the
      # maximum paths and maximum ecmp paths.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_maximum_paths(config)
        values = config.scan(/maximum-paths\s+(\d+)\s+ecmp\s+(\d+)/).first
        { maximum_paths: values[0].to_i, maximum_ecmp_paths: values[1].to_i }
      end
      private :parse_maximum_paths

      ##
      # parse_networks scans the BGP routing configuration for all
      # the network entries.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @return [Array<Hash>] Single element hash with Array of network hashes.
      def parse_networks(config)
        networks = []
        lines = config.scan(%r{network (.+)/(\d+)(?: route-map (\w+))*})
        lines.each do |prefix, mask, rmap|
          rmap = rmap == '' ? nil : rmap
          networks << { prefix: prefix, masklen: mask.to_i, route_map: rmap }
        end
        { networks: networks }
      end
      private :parse_networks

      ##
      # create will create a new instance of BGP routing on the node.
      # Optional parameters can be passed in to initialize BGP specific
      # settings.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #
      # @param bgp_as [String] The BGP autonomous system number to be
      #   configured for the local BGP routing instance.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts router_id [String] The BGP routing process router-id
      #   value.  When no ID has been specified (i.e. value not set), the
      #   local router ID is set to the following:
      #   * The loopback IP address when a single loopback interface is
      #     configured.
      #   * The loopback with the highest IP address when multiple loopback
      #     interfaces are configured.
      #   * The highest IP address on a physical interface when no loopback
      #     interfaces are configure
      #
      # @option opts maximum_paths [Integer] Maximum number of equal cost
      # paths.
      #
      # @option opts maximum_ecmp_paths [Integer] Maximum number of installed
      #   ECMP routes. The maximum_paths option must be set if
      #   maximum_ecmp_paths is set.
      #
      # @option opts enable [Boolean] If true then the BGP router is enabled.
      #   If false then the BGP router is disabled.
      #
      # @return [Boolean] returns true if the command completed successfully.
      def create(bgp_as, opts = {})
        if opts[:maximum_ecmp_paths] && !opts[:maximum_paths]
          message = 'maximum_paths must be set if maximum_ecmp_paths is set'
          raise ArgumentError, message
        end
        cmds = ["router bgp #{bgp_as}"]
        if opts.key?(:enable)
          cmds << (opts[:enable] == true ? 'no shutdown' : 'shutdown')
        end
        cmds << "router-id #{opts[:router_id]}" if opts.key?(:router_id)
        if opts.key?(:maximum_paths)
          cmd = "maximum-paths #{opts[:maximum_paths]}"
          if opts.key?(:maximum_ecmp_paths)
            cmd << " ecmp #{opts[:maximum_ecmp_paths]}"
          end
          cmds << cmd
        end
        configure(cmds)
      end

      ##
      # delete will delete the BGP routing instance from the node.
      #
      # ===Commands
      #   no router bgp <bgp_as>
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete
        config = get
        return true unless config
        configure("no router bgp #{config[:bgp_as]}")
      end

      ##
      # default will configure the BGP routing  using the default
      # keyword.  This command has the same effect as deleting the BGP
      # routine instance from the nodes running configuration.
      #
      # ===Commands
      #   default router bgp <bgp_as>
      #
      # @return [Boolean] returns true if the command complete successfully
      def default
        config = get
        return true unless config
        configure("default router bgp #{config[:bgp_as]}")
      end

      ##
      # configure_bgp adds the command to go to BGP config mode.
      # Then it adds the passed in command. The commands are then
      # passed on to configure.
      #
      # @api private
      #
      # @param cmd [String] Command to run under BGP mode.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def configure_bgp(cmd)
        config = get_block('^router bgp .*')
        raise 'BGP router is not configured' unless config
        bgp_as = Bgp.parse_bgp_as(config)
        cmds = ["router bgp #{bgp_as[:bgp_as]}", cmd]
        configure(cmds)
      end
      private :configure_bgp

      ##
      # set_router_id sets the router_id for the BGP routing instance.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} router-id <router_id>
      #
      # @param opts [hash] Optional keyword arguments
      #
      # @option opts value [String] The BGP routing process router-id
      #   value. When no ID has been specified (i.e. value not set), the
      #   local router ID is set to the following:
      #   * The loopback IP address when a single loopback interface is
      #     configured.
      #   * The loopback with the highest IP address when multiple loopback
      #     interfaces are configured.
      #   * The highest IP address on a physical interface when no loopback
      #     interfaces are configure
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the router-id using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_router_id(opts = {})
        configure_bgp(command_builder('router-id', opts))
      end

      ##
      # set_shutdown configures the administrative state for the global
      # BGP routing process. The value option is not used by this method.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} shutdown
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If enable is true then the BGP
      #   routing process is administratively enabled and if enable is
      #   False then the BGP routing process is administratively
      #   disabled.
      #
      # @option opts default [Boolean] Configure the router-id using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_shutdown(opts = {})
        raise 'set_shutdown has the value option set' if opts[:value]
        # Shutdown semantics are opposite of enable semantics so invert enable
        value = !opts[:enable]
        opts[:enable] = value
        configure_bgp(command_builder('shutdown', opts))
      end

      ##
      # set_maximum_paths sets the maximum number of equal cost paths and
      # the maximum number of installed ECMP routes.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default}
      #       maximum-paths <maximum_paths> [ecmp <maximum_ecmp_paths>]
      #
      # @param maximum_paths [Integer] Maximum number of equal cost paths.
      #
      # @param maximum_ecmp_paths [Integer] Maximum number of installed ECMP
      #   routes.
      #
      # @param opts [hash] Optional keyword arguments
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the maximum paths using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_maximum_paths(maximum_paths, maximum_ecmp_paths, opts = {})
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          cmd = 'default maximum-paths'
        when false
          if enable
            cmd = "maximum-paths #{maximum_paths} ecmp #{maximum_ecmp_paths}"
          else
            cmd = 'no maximum-paths'
          end
        end
        configure_bgp(cmd)
      end

      ##
      # add_network creates a new instance of a BGP network on the node.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     network <prefix>/<masklen>
      #     route-map <route_map>
      #
      # @param prefix [String] The IPv4 prefix to configure as part of
      #   the network statement. The value must be a valid IPv4 prefix.
      #
      # @param masklen [String] The IPv4 subnet mask length in bits.
      #   The masklen must be in the valid range of 1 to 32.
      #
      # @param route_map [String] The route-map name to apply to the
      #   network statement when configured.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def add_network(prefix, masklen, route_map = nil)
        cmd = "network #{prefix}/#{masklen}"
        cmd << " route-map #{route_map}" if route_map
        configure_bgp(cmd)
      end

      ##
      # remove_network removes the instance of a BGP network on the node.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no} shutdown
      #
      # @param prefix [String] The IPv4 prefix to configure as part of
      #   the network statement.  The value must be a valid IPv4 prefix.
      #
      # @param masklen [String] The IPv4 subnet mask length in bits.
      #   The masklen must be in the valid range of 1 to 32.
      #
      # @param route_map [String] The route-map name to apply to the
      #   network statement when configured.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def remove_network(prefix, masklen, route_map = nil)
        cmd = "no network #{prefix}/#{masklen}"
        cmd << " route-map #{route_map}" if route_map
        configure_bgp(cmd)
      end
    end

    ##
    # The BgpNeighbors class implements BGP neighbor configuration
    class BgpNeighbors < Entity
      ##
      # get returns a single BGP neighbor entry from the nodes current
      # configuration.
      #
      # @example
      #   {
      #     peer_group: <string>,
      #     remote_as: <string>,
      #     send_community: <string>,
      #     shutdown: <boolean>,
      #     description: <integer>
      #     next_hop_self: <boolean>
      #     route_map_in: <string>
      #     route_map_out: <string>
      #   }
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [nil, Hash<Symbol, Object>] Returns the BGP neighbor
      #   resource as a Hash.
      def get(name)
        config = get_block('^router bgp .*')
        return nil unless config

        response = parse_peer_group(config, name)
        response.merge!(parse_remote_as(config, name))
        response.merge!(parse_send_community(config, name))
        response.merge!(parse_shutdown(config, name))
        response.merge!(parse_description(config, name))
        response.merge!(parse_next_hop_self(config, name))
        response.merge!(parse_route_map_in(config, name))
        response.merge!(parse_route_map_out(config, name))
        response
      end

      ##
      # getall returns the collection of all neighbor entries for the
      # BGP router instance.
      #
      # @example
      #   {
      #     <name>: {
      #       peer_group: <string>,
      #       remote_as: <string>,
      #       send_community: <string>,
      #       shutdown: <boolean>,
      #       description: <integer>
      #       next_hop_self: <boolean>
      #       route_map_in: <string>
      #       route_map_out: <string>
      #     },
      #     <name>: {
      #       peer_group: <string>,
      #       remote_as: <string>,
      #       send_community: <string>,
      #       shutdown: <boolean>,
      #       description: <integer>
      #       next_hop_self: <boolean>
      #       route_map_in: <string>
      #       route_map_out: <string>
      #     },
      #     ...
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] Returns a hash that
      #   represents the entire BGP neighbor collection from the nodes
      #   running configuration. If there a BGP router is not configured
      #   or contains no neighbor entries then this method will return
      #   an empty hash.
      def getall
        config = get_block('^router bgp .*')
        return nil unless config

        entries = config.scan(/neighbor ([^\s]+)/)
        entries.uniq.each_with_object({}) do |name, hsh|
          resource = get(name[0])
          hsh[name[0]] = resource if resource
        end
      end

      ##
      # parse_peer_group scans the BGP neighbor entries for the
      # peer group.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_peer_group(config, name)
        value = config.scan(/neighbor #{name} peer-group ([^\s]+)/)
        peer_group = value[0] ? value[0][0] : nil
        { peer_group: peer_group }
      end
      private :parse_peer_group

      ##
      # parse_remote_as scans the BGP neighbor entries for the
      # remote AS.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute
      def parse_remote_as(config, name)
        value = config.scan(/neighbor #{name} remote-as (\d+)/)
        remote_as = value[0] ? value[0][0] : nil
        { remote_as: remote_as }
      end
      private :parse_remote_as

      ##
      # parse_send_community scans the BGP neighbor entries for the
      # remote AS.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_send_community(config, name)
        value = config.scan(/no neighbor #{name} send-community/)
        enabled = value[0] ? false : true
        { send_community: enabled }
      end
      private :parse_send_community

      ##
      # parse_shutdown scans the BGP neighbor entries for the
      # remote AS.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Resource hash attribute. Returns
      #   true if shutdown, false otherwise.
      def parse_shutdown(config, name)
        value = config.scan(/no neighbor #{name} shutdown/)
        shutdown = value[0] ? false : true
        { shutdown: shutdown }
      end
      private :parse_shutdown

      ##
      # parse_description scans the BGP neighbor entries for the
      # description.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash
      #   attribute.
      def parse_description(config, name)
        value = config.scan(/neighbor #{name} description (.*)$/)
        description = value[0] ? value[0][0] : nil
        { description: description }
      end
      private :parse_description

      ##
      # parse_next_hop_self scans the BGP neighbor entries for the
      # next hop self.
      #
      # @api private
      #
      # @param config [String] The switch config.
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash
      #   attribute.
      def parse_next_hop_self(config, name)
        value = config.scan(/no neighbor #{name} next-hop-self/)
        enabled = value[0] ? false : true
        { next_hop_self: enabled }
      end
      private :parse_next_hop_self

      ##
      # parse_route_map_in scans the BGP neighbor entries for the
      # route map in.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash
      #   attribute.
      def parse_route_map_in(config, name)
        value = config.scan(/neighbor #{name} route-map ([^\s]+) in/)
        route_map_in = value[0] ? value[0][0] : nil
        { route_map_in: route_map_in }
      end
      private :parse_route_map_in

      ##
      # parse_route_map_out scans the BGP neighbor entries for the
      # route map in.
      #
      # @api private
      #
      # @param config [String] The switch config.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash
      #   attribute.
      def parse_route_map_out(config, name)
        value = config.scan(/neighbor #{name} route-map ([^\s]+) out/)
        route_map_out = value[0] ? value[0][0] : nil
        { route_map_out: route_map_out }
      end
      private :parse_route_map_out

      ##
      # configure_bgp adds the command to go to BGP config mode.
      # Then it adds the passed in command. The commands are then
      # passed on to configure.
      #
      # @api private
      #
      # @param cmd [String] Command to run under BGP mode.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def configure_bgp(cmd)
        config = get_block('^router bgp .*')
        raise 'BGP router is not configured' unless config
        bgp_as = Bgp.parse_bgp_as(config)
        cmds = ["router bgp #{bgp_as[:bgp_as]}", cmd]
        configure(cmds)
      end
      private :configure_bgp

      ##
      # create will create a new instance of a BGP neighbor on the node.
      # The neighbor is created in the shutdown state and then enabled.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(name)
        set_shutdown(name, enable: false)
      end

      ##
      # delete will delete the BGP neighbor from the node.
      #
      # ===Commands
      #   no neighbor <name>
      #     or
      #   no neighbor <name> peer-group
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(name)
        cmd = "no neighbor #{name}"
        response = configure_bgp(cmd)
        unless response
          cmd = "no neighbor #{name} peer-group"
          response = configure_bgp(cmd)
        end
        response
      end

      ##
      # neigh_command_builder for neighbors which calls command_builder.
      #
      # @param name [String] The name of the BGP neighbor to manage.
      #
      # @param cmd [String] The command portion of the neighbor command.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] Value being set.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the command using
      #   the default keyword.
      #
      # @return [String] Returns built command string.
      def neigh_command_builder(name, cmd, opts)
        command_builder("neighbor #{name} #{cmd}", opts)
      end

      ##
      # set_peer_group creates a BGP static peer group name.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> peer-group <group-name>
      #
      # @param name [String] The IP address of the neighbor.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] The group name.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_peer_group(name, opts = {})
        configure_bgp(neigh_command_builder(name, 'peer-group', opts))
      end

      ##
      # set_remote_as configures the expected AS number for a neighbor
      # (peer).
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> remote-as <as-id>
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] The remote as-id.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_remote_as(name, opts = {})
        configure_bgp(neigh_command_builder(name, 'remote-as', opts))
      end

      ##
      # set_shutdown disables the specified neighbor. The value option is
      # not used by this method.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> shutdown
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [String] True enables the specified neighbor.
      #   False disables the specified neighbor.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_shutdown(name, opts = {})
        raise 'set_shutdown has value option set' if opts[:value]
        # Shutdown semantics are opposite of enable semantics so invert enable.
        value = !opts[:enable]
        opts[:enable] = value
        configure_bgp(neigh_command_builder(name, 'shutdown', opts))
      end

      ##
      # set_send_community configures the switch to send community
      # attributes to the specified BGP neighbor. The value option is
      # not used by this method.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> send-community
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [String] True enables the feature. False
      #   disables the feature.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_send_community(name, opts = {})
        raise 'send_community has the value option set' if opts[:value]
        configure_bgp(neigh_command_builder(name, 'send-community', opts))
      end

      ##
      # set_next_hop_self configures the switch to list its address as
      # the next hop in routes that it advertises to the specified
      # BGP-speaking neighbor or neighbors in the specified peer group.
      # The value option is not used by this method.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> next-hop-self
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [String] True enables the feature. False
      #   disables the feature.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_next_hop_self(name, opts = {})
        raise 'set_next_hop_self has the value option set' if opts[:value]
        configure_bgp(neigh_command_builder(name, 'next-hop-self', opts))
      end

      ##
      # set_route_map_in command applies a route map to inbound BGP
      # routes.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> route-map <name> in
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] Name of a route map.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_route_map_in(name, opts = {})
        cmd = neigh_command_builder(name, 'route-map', opts) + ' in'
        configure_bgp(cmd)
      end

      ##
      # set_route_map_out command applies a route map to outbound BGP
      # routes.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> route-map <name> out
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] Name of a route map.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_route_map_out(name, opts = {})
        cmd = neigh_command_builder(name, 'route-map', opts) + ' out'
        configure_bgp(cmd)
      end

      ##
      # set_description associates descriptive text with the specified
      # peer or peer group.
      #
      # ===Commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> description <string>
      #
      # @param name [String] The IP address or name of the peer group.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] The description string.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the peer group using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def set_description(name, opts = {})
        configure_bgp(neigh_command_builder(name, 'description', opts))
      end
    end
  end
end
