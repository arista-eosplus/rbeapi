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
    # The Varp class provides an instance for working with the global
    # VARP configuration of the node
    class Varp < Entity
      ##
      # Returns the global VARP configuration from the node
      #
      # Example
      #   {
      #     "mac_address": <string>,
      #     "interfaces": {...}
      #   }
      #
      # @return [Hash]  A Ruby hash object that provides the Varp settings as
      #   key / value pairs.
      def get
        response = {}

        regex = /(?<=^ip\svirtual-router\smac-address\s)
          ((?:[a-f0-9]{2}:){5}[a-f0-9]{2})$/x

        mdata = regex.match(config)
        response['mac_address'] = mdata.nil? ? '' : mdata[1]
        response['interfaces'] = interfaces.getall
        response
      end

      def interfaces
        return @interfaces if @interfaces
        @interfaces = VarpInterfaces.new(node)
        @interfaces
      end

      ##
      # Configure the VARP virtual-router mac-address value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the mac-address to
      # @option opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_mac_address(opts = {})
        cmd = command_builder('ip virtual-router mac-address', opts)
        configure(cmd)
      end
    end

    ##
    # The VarpInterfaces class provides an instance for working with the global
    # VARP interface configuration of the node
    class VarpInterfaces < Entity
      ##
      # Returns a single VARP interface configuration
      #
      # Example
      #   {
      #     "name": <string>,
      #     "addresses": array<string>
      #   }
      #
      # @param [String] :name The interface name to return the configuration
      #   values for.  This must be the full interface identifier.
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   VARP interface configuration.  A nil object is returned if the
      #   specified interface is not configured
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config
        addrs = config.scan(/(?<=\s{3}ip\svirtual-router\saddress\s).+$/)
        { 'addresses' => addrs }
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
      #   MLAG interface configuration.  A nil object is returned if no
      #   interfaces are configured.
      def getall
        interfaces = config.scan(/(?<=^interface\s)(Vl.+)$/)
        interfaces.first.each_with_object({}) do |name, resp|
          data = get(name)
          resp[name] = data if data
        end
      end

      ##
      # The set_addresses method assigns one or more virtual IPv4 address
      # to the specified VLAN interface. All existing addresses are
      # removed before the ones in value are added.
      #
      # @param [String] :name The name of the interface.  The
      #   name argument must be the full interface name.  Valid interfaces
      #   are restricted to VLAN interfaces
      # @param [Hash] opts The configuration parameters
      # @option opts [Array] :value Array of IPv4 addresses to add to
      #   the virtual router.
      # @option opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeeds otherwise False
      def set_addresses(name, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          configure(["interface #{name}", 'default ip virtual-router address'])
        when false
          get(name)['addresses'].each do |addr|
            result = remove_address(name, addr)
            return result unless result
          end
          if enable
            value.each do |addr|
              result = add_address(name, addr)
              return result unless result
            end
          end
        end
        true
      end

      def add_address(name, value)
        configure(["interface #{name}", "ip virtual-router address #{value}"])
      end

      def remove_address(name, value)
        configure(["interface #{name}",
                   "no ip virtual-router address #{value}"])
      end
    end
  end
end
