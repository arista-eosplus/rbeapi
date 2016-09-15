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
    # The Ospf class is a global class that provides an instance for working
    # with the node's OSPF configuration.
    class Ospf < Entity
      ##
      # Returns the global OSPF configuration from the node.
      #
      # rubocop:disable Metrics/MethodLength
      #
      # @example
      #   {
      #     router_id: <string>,
      #     max_lsa: <integer>,
      #     maximum_paths: <integer>,
      #     passive_interface_default <boolean>,
      #     passive_interfaces: array<string>,
      #     active_interfaces: array<string>,
      #     areas: {
      #       <string>: array<string>
      #     },
      #     redistribute: {}
      #   }
      #
      # @param inst [String] The ospf instance name.
      #
      # @return [Hash] A Ruby hash object that provides the OSPF settings as
      #   key / value pairs.
      def get(inst)
        config = get_block("router ospf #{inst}")
        return nil unless config

        response = {}
        mdata = /(?<=^\s{3}router-id\s)(.+)$/.match(config)
        response['router_id'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=^\s{3}max-lsa\s)(\d+)(?=.*$)/.match(config)
        response['max_lsa'] = mdata.nil? ? '' : mdata[0].to_i

        mdata = /(?<=^\s{3}maximum-paths\s)(\d+)$/.match(config)
        response['maximum_paths'] = mdata.nil? ? '' : mdata[0].to_i

        mdata = /^\s{3}passive-interface default$/ =~ config
        response['passive_interface_default'] = !mdata.nil?

        response['passive_interfaces'] =
          config.scan(/(?<=^\s{3}passive-interface\s)(?!default)(.*)$/)
          .flatten!.to_a

        response['active_interfaces'] =
          config.scan(/(?<=^\s{3}no passive-interface\s)(.*)$/).flatten!.to_a

        # active interface regex: (?<=^\s{3}no passive-interface\s)(.*)$

        networks = config.scan(/^\s{3}network\s(.+)\sarea\s(.+)$/)
        areas = networks.each_with_object({}) do |cfg, hsh|
          net, area = cfg
          if hsh.include?(area)
            hsh[area] << net
          else
            hsh[area] = [net]
          end
        end
        response['areas'] = areas

        values = \
          config.scan(/(?<=^\s{3}redistribute\s)(\w+)[\s|$]*(route-map\s(.+))?/)

        response['redistribute'] = values.each_with_object({}) do |value, hsh|
          hsh[value[0]] = { 'route_map' => value[2] }
        end
        response
      end

      ##
      # Returns the OSPF configuration from the node as a Ruby hash.
      #
      # @example
      #   {
      #     <pid>: {
      #       router_id: <string>,
      #       max_lsa: <integer>,
      #       maximum_paths: <integer>,
      #       passive_interface_default <boolean>,
      #       passive_interfaces: array<string>,
      #       active_interfaces: array<string>,
      #       areas: {},
      #       redistribute: {}
      #     },
      #     interfaces: {}
      #   }
      #
      # @return [Hash] A Ruby hash object that provides the OSPF settings as
      #   key / value pairs.
      def getall
        instances = config.scan(/(?<=^router\sospf\s)\d+$/)
        response = instances.each_with_object({}) do |inst, hsh|
          hsh[inst] = get inst
        end
        response['interfaces'] = interfaces.getall
        response
      end

      def interfaces
        @interfaces if @interfaces
        @interfaces = OspfInterfaces.new(node)
        @interfaces
      end

      ##
      # create will create a router ospf with the specified pid.
      #
      # @param pid [String] The router ospf to create.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(pid)
        configure "router ospf #{pid}"
      end

      ##
      # delete will remove the specified router ospf.
      #
      # @param pid [String] The router ospf to remove.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(pid)
        configure "no router ospf #{pid}"
      end

      ##
      # set_router_id sets router ospf router-id with pid and options.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the router-id to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_router_id(pid, opts = {})
        cmd = command_builder('router-id', opts)
        cmds = ["router ospf #{pid}", cmd]
        configure cmds
      end

      ##
      # set_max_lsa sets router ospf max-lsa with pid and options.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the max-lsa to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_max_lsa(pid, opts = {})
        cmd = command_builder('max-lsa', opts)
        cmds = ["router ospf #{pid}", cmd]
        configure cmds
      end

      ##
      # set_maximum_paths sets router ospf maximum-paths with pid and options.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the maximum-paths to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_maximum_paths(pid, opts = {})
        cmd = command_builder('maximum-paths', opts)
        cmds = ["router ospf #{pid}", cmd]
        configure cmds
      end

      ##
      # set_passive_interface_default sets router ospf passive-interface
      # default with pid and options. If the passive-interface default keyword
      # is false, then the
      # passive-interface default is disabled. If the enable keyword is true,
      # then the passive-interface default is enabled. If the default keyword
      # is set to true, then the passive-interface default is configured using
      # the default keyword. The default keyword takes precedence ver the
      # enable keyword if both are provided.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the passive-interface default
      # to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_passive_interface_default(pid, opts = {})
        opts[:enable] = opts[:value] | false
        opts[:value] = nil
        cmd = command_builder('passive-interface default', opts)
        cmds = ["router ospf #{pid}", cmd]
        configure cmds
      end

      ##
      # set_active_interfaces sets router ospf no passive interface with pid
      # and options, when passive interfaces default is configured.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the active interface to
      # default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_active_interfaces(pid, opts = {})
        values = opts[:value]
        current = get(pid)['active_interfaces']
        cmds = ["router ospf #{pid}"]
        current.each do |name|
          cmds << "passive-interface #{name}" unless Array(values).include?(name)
        end
        Array(values).each do |name|
          cmds << "no passive-interface #{name}"
        end
        configure cmds
      end

      ##
      # set_passive_interfaces sets router ospf passive interface with pid
      # and options.
      #
      # @param pid [String] The router ospf name.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the passive interface to
      # default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_passive_interfaces(pid, opts = {})
        values = opts[:value]
        current = get(pid)['passive_interfaces']
        cmds = ["router ospf #{pid}"]
        current.each do |name|
          cmds << "no passive-interface #{name}" unless Array(values).include?(name)
        end
        Array(values).each do |name|
          cmds << "passive-interface #{name}"
        end
        configure cmds
      end

      ##
      # add_network adds network settings for router ospf and network area.
      #
      # @param pid [String] The pid for router ospf.
      #
      # @param net [String] The network name.
      #
      # @param area [String] The network area name.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def add_network(pid, net, area)
        configure ["router ospf #{pid}", "network #{net} area #{area}"]
      end

      ##
      # remove_network removes network settings for router ospf and network
      #   area.
      #
      # @param pid [String] The pid for router ospf.
      #
      # @param net [String] The network name.
      #
      # @param area [String] The network area name.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def remove_network(pid, net, area)
        configure ["router ospf #{pid}", "no network #{net} area #{area}"]
      end

      ##
      # set_redistribute sets router ospf router-id with pid and options.
      #
      # @param pid [String] The router ospf name.
      #
      # @param proto [String] The redistribute value.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts routemap [String] The route-map value.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the router-id to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_redistribute(pid, proto, opts = {})
        routemap = opts[:routemap]
        cmds = ["router ospf #{pid}", "redistribute #{proto}"]
        cmds[1] << " route-map #{routemap}" if routemap
        configure cmds
      end
    end

    ##
    # The OspfInterfaces class is a global class that provides an instance
    # for working with the node's OSPF interface configuration.
    class OspfInterfaces < Entity
      ##
      # Returns a single MLAG interface configuration.
      #
      # Example
      #   {
      #      network_type: <string>
      #   }
      #
      # @param name [String] The interface name to return the configuration
      #   values for. This must be the full interface identifier.
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface configuration. A nil object is returned if the
      #   specified interface is not configured
      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil unless /no switchport$/ =~ config

        response = {}
        nettype = /ip ospf network point-to-point/ =~ config
        response['network_type'] = nettype.nil? ? 'broadcast' : 'point-to-point'
        response
      end

      ##
      # Returns the collection of MLAG interfaces as a hash index by the
      # interface name.
      #
      # Example
      #   {
      #     <name>: {
      #       network_type: <string>
      #     },
      #     <name>: {
      #       network_type: <string>
      #     },
      #     ...
      #   }
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface configuration. A nil object is returned if no
      #   interfaces are configured.
      def getall
        interfaces = config.scan(/(?<=interface\s)[Et|Po|Lo|Vl].+/)
        interfaces.each_with_object({}) do |intf, hsh|
          values = get(intf)
          hsh[intf] = values if values
        end
      end

      ##
      # set_network_type sets network type with options.
      #
      # @param name [String] The name of the interface.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts value [String] The point-to-point value.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ip ospf network
      #   to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_network_type(name, opts = {})
        value = opts[:value]
        return false unless [nil, 'point-to-point'].include?(value)
        cmd = command_builder('ip ospf network', opts)
        configure_interface(name, cmd)
      end
    end
  end
end
