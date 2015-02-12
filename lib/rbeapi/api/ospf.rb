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

  module Api

    ##
    # The Ospf class is a global class that provides an instance for working
    # with the node's OSPF configuration
    class Ospf < Entity

      ##
      # Returns the global OSPF configuration from the node
      #
      # @example
      #   {
      #     "router_id": <string>
      #     "areas": {
      #       <string>: array<string>
      #     },
      #     "resdistribute"
      #   }
      #
      # @return [Hash]  A Ruby hash object that provides the OSPF settings as
      #   key / value pairs.
      def get(inst)
        config = get_block("router ospf #{inst}")
        return nil unless config

        resp = {}
        mdata = /(?<=^\s{3}router-id\s)(.+)$/.match(config)
        resp['router_id'] = mdata.nil? ? '' : mdata[0]

        mdata = /^\s{3}network\s(.+)\sarea\s(.+)$/.match(config)
        networks = config.scan(/^\s{3}network\s(.+)\sarea\s(.+)$/)
        areas = networks.each_with_object({}) do |cfg, hsh|
          net, area = cfg
          if hsh.include?(area)
            hsh[area] << net
          else
            hsh[area] = [net]
          end
        end
        resp['areas'] = areas

        values = config.scan(/(?<=^\s{3}redistribute\s)(\w+)[\s|$]*(route-map\s(.+))?/)

        resp['redistribute'] = values.each_with_object({}) do |value, hsh|
          hsh[value[0]] = { 'route_map' => value[2] }
        end
        resp
      end

      ##
      # Returns the OSPF configuration from the node as a Ruby hash
      #
      # @example
      # {
      #   <pid>: {...}
      #   "interfaces": {...}
      # }
      def getall
        response = {}

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

      def create(pid)
        configure "router ospf #{pid}"
      end

      def delete(pid)
        configure "no router ospf #{pid}"
      end

      def set_router_id(pid, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["router ospf #{pid}"]
        case default
        when true
          cmds << 'default router-id'
        when false
          cmds << (value ? "router-id #{value}" : 'no router-id')
        end
        configure cmds
      end

      def add_network(pid, net, area)
        configure ["router ospf #{pid}", "network #{net} area #{area}"]
      end

      def remove_network(pid, net, area)
        configure ["router ospf #{pid}", "no network #{net} area #{area}"]
      end

      def set_redistribute(pid, proto, opts = {})
        routemap = opts[:routemap]
        cmds = ["router ospf #{pid}", "redistribute #{proto}"]
        cmds[1] << " route-map #{routemap}" if routemap
        configure cmds
      end
    end

    class OspfInterfaces < Entity

      ##
      # Returns a single MLAG interface configuration
      #
      # Example
      #   {
      #     "name": <string>,
      #     "network_type": <string>
      #   }
      #
      # @param [String] :name The interface name to return the configuration
      #   values for.  This must be the full interface identifier.
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface confguration.  A nil object is returned if the
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
      # interface name
      #
      # Example
      #   {
      #     <name>: {...},
      #     <name>: {...}
      #   }
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface confguration.  A nil object is returned if no
      #   interfaces are configured.
      def getall
        interfaces = config.scan(/(?<=interface\s)[Et|Po|Lo|Vl].+/)
        interfaces.each_with_object({}) do |intf, hsh|
          values = get(intf)
          hsh[intf] = values if values
        end
      end

      def set_network_type(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        return false unless %w(nil point-to-point).include?(value)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default ip ospf network'
        when false
          cmds << (value ? "ip ospf network #{value}" : 'no ip ospf netework')
        end
        configure(cmds)
      end
    end
  end
end
