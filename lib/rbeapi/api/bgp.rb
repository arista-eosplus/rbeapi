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
require 'netaddr'
require 'rbeapi/api'

##
# Eos is the toplevel namespace for working with Arista EOS nodes
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API
  module Api
    ##
    # The Bgp class implements global BGP router configuration
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
      # @return [nil, Hash<Symbol, Object>] Returns the BGP resource as a
      #   Hash.
      def get
        config = get_block('^router bgp .*')
        return {} unless config

        response = Bgp.parse_bgp_as(config)
        response.merge!(parse_router_id(config))
        response.merge!(parse_shutdown(config))
        response.merge!(parse_networks(config))
        response[:neighbors] = @neighbors.getall
        response
      end

      ##
      # parse_bgp_as scans the BGP routing configuration for the
      # AS number. Used by the BgpNeighbors class below.
      #
      # @param [String] :config The switch config.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_shutdown(config)
        value = config.include?('no shutdown')
        { shutdown: !value }
      end
      private :parse_shutdown

      ##
      # parse_networks scans the BGP routing configuration for all
      # the network entries.
      #
      # @api private
      #
      # @param [String] :config The switch config.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_networks(config)
        networks = {}
        lines = config.scan(%r{network (.+)/(\d+)(?: route-map (\w+))*})
        lines.each do |prefix, mask, rmap|
          rmap = rmap == '' ? nil : rmap
          networks.merge!(prefix: prefix, masklen: mask.to_i, route_map: rmap)
        end
        { networks: networks }
      end
      private :parse_networks

      ##
      # create will create a new instance of BGP routing on the node.
      #
      # @commands
      #   router bgp <bgp_as>
      #
      # @param [String] :bgp_as The BGP autonomous system number to be
      #   configured for the local BGP routing instance.
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(bgp_as)
        value = bgp_as.to_i
        configure("router bgp #{value}")
      end

      ##
      # delete will delete the BGP routing instance from the node.
      #
      # @commands
      #   no router bgp <bgp_as>
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete
        config = get
        return True unless config
        configure("no router bgp #{config[:bgp_as]}")
      end

      ##
      # default will configure the BGP routing  using the default
      # keyword.  This command has the same effect as deleting the BGP
      # routine instance from the nodes running configuration.
      #
      # @commands
      #   default router bgp <bgp_as>
      #
      # @return [Boolean] returns true if the command complete successfully
      def default
        config = get
        return True unless config
        configure("default router bgp #{config[:bgp_as]}")
      end

      ##
      # configure_bgp returns the command to place the switch in
      # router-BGP configuration mode. Fails if the BGP router
      # is not configured.
      #
      # @api private
      #
      # @return [Array] returns command string as only member of array
      def configure_bgp
        config = get
        fail 'BGP router is not configured' unless config
        ["router bgp #{config[:bgp_as]}"]
      end
      private :configure_bgp

      ##
      # set_router_id sets the router_id for the BGP routing instance.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} router-id <router_id>
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The BGP routing process router-id
      #   value.  When no ID has been specified (i.e. value not set), the
      #   local router ID is set to the following:
      #   * The loopback IP address when a single loopback interface is
      #     configured.
      #   * The loopback with the highest IP address when multiple loopback
      #     interfaces are configured.
      #   * The highest IP address on a physical interface when no loopback
      #     interfaces are configure
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the router-id using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_router_id(opts = {})
        cmds = configure_bgp
        cmds << command_builder('router-id', opts)
        configure(cmds)
      end

      ##
      # set_shutdown configures the administrative state for the global
      # BGP routing process.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} shutdown
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :enable If enable is True then the BGP
      #   routing process is administratively enabled and if enable is
      #   False then the BGP routing process is administratively
      #   disabled.
      #
      # @option :opts [Boolean] :default Configure the router-id using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_shutdown(opts = {})
        cmds = configure_bgp
        cmds << command_builder('shutdown', opts)
        configure(cmds)
      end

      ##
      # add_network creates a new instance of a BGP network on the node.
      #
      # @commands
      #   router bgp <bgp_as>
      #     network <prefix>/<masklen>
      #     route-map <route_map>
      #
      # @param [String] :prefix The IPv4 prefix to configure as part of
      #   the network statement.  The value must be a valid IPv4 prefix.
      # @param [String] :masklen The IPv4 subnet mask length in bits.
      #   The masklen must be in the valid range of 1 to 32.
      # @param [String] :route_map The route-map name to apply to the
      #   network statement when configured.
      #
      # @return [Boolean] returns true if the command complete successfully
      def add_network(prefix, masklen, route_map = nil)
        cmds = configure_bgp
        cmds << "network #{prefix}/#{masklen}"
        cmds << "route-map #{route_map}" if route_map
        configure(cmds)
      end

      ##
      # remove_network removes the instance of a BGP network on the node.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no} shutdown
      #
      # @param [String] :prefix The IPv4 prefix to configure as part of
      #   the network statement.  The value must be a valid IPv4 prefix.
      # @param [String] :masklen The IPv4 subnet mask length in bits.
      #   The masklen must be in the valid range of 1 to 32.
      # @param [String] :route_map The route-map name to apply to the
      #   network statement when configured.
      #
      # @return [Boolean] returns true if the command complete successfully
      def remove_network(prefix, masklen, route_map = nil)
        cmds = configure_bgp
        cmds << "no network #{prefix}/#{masklen}"
        cmds << "route-map #{route_map}" if route_map
        configure(cmds)
      end
    end

    ##
    # The BgpNeighbors class implements BGP neighbor configuration
    # rubocop:disable Metrics/ClassLength
    class BgpNeighbors < Entity
      ##
      # get returns a single BGP neighbor entry from the nodes current
      # configuration.
      #
      # @param [String] :name The name of the BGP neighbor to manage.
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_send_community(config, name)
        value = config.scan(/no neighbor #{name} send_community/)
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_shutdown(config, name)
        value = config.scan(/no neighbor #{name} shutdown/)
        enabled = value[0] ? false : true
        { shutdown: enabled }
      end
      private :parse_shutdown

      ##
      # parse_description scans the BGP neighbor entries for the
      # description.
      #
      # @api private
      #
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
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
      # @param [String] :config The switch config.
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_route_map_out(config, name)
        value = config.scan(/neighbor #{name} route-map ([^\s]+) out/)
        route_map_out = value[0] ? value[0][0] : nil
        { route_map_out: route_map_out }
      end
      private :parse_route_map_out

      ##
      # configure_bgp returns the command to place the switch in
      # router-BGP configuration mode. Fails if the BGP router
      # is not configured.
      #
      # @api private
      #
      # @return [Array] returns command string as only member of array
      def configure_bgp
        config = get_block('^router bgp .*')
        fail 'BGP router is not configured' unless config
        bgp_as = Bgp.parse_bgp_as(config)
        ["router bgp #{bgp_as[:bgp_as]}"]
      end
      private :configure_bgp

      ##
      # ispeergroup checks if name is a peer group name. If it is not
      # a valid IPv4 address then it is assumed to be a peer group name.
      #
      # @api private
      #
      # @param [String] :name The name of the BGP neighbor to manage.
      #
      # @return [Boolean] returns true if the name is a peer group name
      def ispeergroup(name)
        Netaddr.validate_ip_addr(name)
        return false
      rescue Netaddr::ValidationError
        return true
      end
      private :ispeergroup

      ##
      # create will create a new instance of a BGP neighbor on the node.
      # The neighbor is created in the shutdown state and then enabled.
      #
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(name)
        set_shutdown(name, enable: true)
      end

      ##
      # delete will delete the BGP neighbor from the node.
      #
      # @commands
      #   no neighbor <name>
      #     or
      #   no neighbor <name> peer-group
      #
      # @param [String] :name The name of the BGP neighbor to manage.
      #   This value can be either an IPv4 address or string (in the
      #   case of managing a peer group).
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(name)
        bgp_cmd = configure_bgp
        cmds = bgp_cmd
        cmds << "no neighbor #{name}"
        response = configure(cmds)
        unless response
          cmds = bgp_cmd
          cmds << "no neighbor #{name} peer-group"
          response = configure(cmds)
        end
        response
      end

      ##
      # neigh_command_builder for neighbors which calls command_builder
      #
      # @param [String] :name The name of the BGP neighbor to manage.
      # @param [String] :cmd The command portion of the neighbor command.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value Value being set.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the command using
      #   the default keyword.
      #
      # @return [String] Returns built command string
      def neigh_command_builder(name, cmd, opts)
        command_builder("neighbor #{name} #{cmd}", opts)
      end

      ##
      # set_peer_group sets BGP neighbors to an existing static peer
      # group.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> peer-group <group-name>
      #
      # @param [String] :name The name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The address of neighbor being
      #   added to peer group.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_peer_group(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'peer-group', opts)
        configure(cmds)
      end

      ##
      # set_remote_as configures the expected AS number for a neighbor
      # (peer).
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> remote-as <as-id>
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The remote as-id.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_remote_as(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'remote-as', opts)
        configure(cmds)
      end

      ##
      # set_shutdown disables the specified neighbor.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> shutdown
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :enable True enables the specified peer.
      #   False disables the specified peer.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_shutdown(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'shutdown', opts)
        configure(cmds)
      end

      ##
      # set_send_community configures the switch to send community
      # attributes to the specified BGP neighbor.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> send-community
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :enable True enables the feature. False
      #   disables the feature.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_send_community(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'send-community', opts)
        configure(cmds)
      end

      ##
      # set_next_hop_self configures the switch to list its address as
      # the next hop in routes that it advertises to the specified
      # BGP-speaking neighbor or neighbors in the specified peer group.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> next-hop-self
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :enable True enables the feature. False
      #   disables the feature.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_next_hop_self(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'next-hop-self', opts)
        configure(cmds)
      end

      ##
      # set_route_map_in command applies a route map to inbound BGP
      # routes.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> route-map <name> in
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value Name of a route map.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_route_map_in(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'route-map', opts) + ' in'
        configure(cmds)
      end

      ##
      # set_route_map_out command applies a route map to outbound BGP
      # routes.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> route-map <name> out
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value Name of a route map.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_route_map_out(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'route-map', opts) + ' out'
        configure(cmds)
      end

      ##
      # set_description associates descriptive text with the specified
      # peer or peer group.
      #
      # @commands
      #   router bgp <bgp_as>
      #     {no | default} neighbor <name> description <string>
      #
      # @param [String] :name The IP address or name of the peer group.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The description string.
      #
      # @option :opts [Boolean] :default Configure the peer group using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_description(name, opts = {})
        cmds = configure_bgp
        cmds << neigh_command_builder(name, 'description', opts)
        configure(cmds)
      end
    end
  end
end
