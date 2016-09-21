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
    # The Varp class provides an instance for working with the global
    # VARP configuration of the node.
    class Varp < Entity
      ##
      # Returns the global VARP configuration from the node.
      #
      # @example
      #   {
      #     mac_address: <string>,
      #     interfaces: {
      #       <name>: {
      #         addresses: <array>
      #       },
      #       <name>: {
      #         addresses: <array>
      #       },
      #       ...
      #     }
      #   }
      #
      # @return [Hash] A Ruby hash object that provides the Varp settings as
      #   key / value pairs.
      def get
        response = {}
        response.merge!(parse_mac_address(config))
        response[:interfaces] = interfaces.getall
        response
      end

      ##
      # parse_mac_address parses mac-address values from the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_mac_address(config)
        # ip virtual-router mac-address value will always
        #   be stored in aa:bb:cc:dd:ee:ff format.
        regex = /mac-address ((?:[a-f0-9]{2}:){5}[a-f0-9]{2})$/
        mdata = regex.match(config)
        { mac_address: mdata.nil? ? '' : mdata[1] }
      end
      private :parse_mac_address

      def interfaces
        return @interfaces if @interfaces
        @interfaces = VarpInterfaces.new(node)
        @interfaces
      end

      ##
      # Configure the VARP virtual-router mac-address value.
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts value [string] The value to set the mac-address to.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_mac_address(opts = {})
        cmd = command_builder('ip virtual-router mac-address', opts)
        configure(cmd)
      end
    end

    ##
    # The VarpInterfaces class provides an instance for working with the global
    # VARP interface configuration of the node.
    class VarpInterfaces < Entity
      ##
      # Returns a single VARP interface configuration.
      #
      # @example
      #   {
      #     "addresses": array<string>
      #   }
      #
      # @param name [String] The interface name to return the configuration
      #   values for. This must be the full interface identifier.
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   VARP interface configuration. A nil object is returned if the
      #   specified interface is not configured
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config
        response = parse_addresses(config)
        response
      end

      ##
      # Returns the collection of MLAG interfaces as a hash index by the
      # interface name.
      #
      # @example
      #   {
      #     <name>: {
      #       addresses: <array>
      #     },
      #     <name>: {
      #       addresses: <array>
      #     },
      #     ...
      #   }
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface configuration. A nil object is returned if no
      #   interfaces are configured.
      def getall
        interfaces = config.scan(/(?<=^interface\s)(Vl.+)$/)
        return nil unless interfaces

        interfaces.each_with_object({}) do |name, resp|
          data = get(name[0])
          resp[name.first] = data if data
        end
      end

      ##
      # parse_addresses parses ip virtual-router address from the provided
      #   config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_addresses(config)
        addrs = config.scan(/(?<=\s{3}ip\svirtual-router\saddress\s).+$/)
        { addresses: addrs }
      end
      private :parse_addresses

      ##
      # The set_addresses method assigns one or more virtual IPv4 address
      # to the specified VLAN interface. All existing addresses are
      # removed before the ones in value are added.
      #
      # @param name [String] The name of the interface. The
      #   name argument must be the full interface name. Valid interfaces
      #   are restricted to VLAN interfaces.
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts value [Array] Array of IPv4 addresses to add to
      #   the virtual router.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default.
      #
      # @return [Boolean] True if the commands succeeds otherwise False.
      # rubocop:disable Metrics/MethodLength
      def set_addresses(name, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false
        cmds = ["interface #{name}"]

        if value
          fail ArgumentError, 'value must be an Array' unless value.is_a?(Array)
        end

        case default
        when true
          cmds << 'default ip virtual-router address'
        when false
          cmds << 'no ip virtual-router address'
          if enable
            fail ArgumentError,
                 'no values for addresses provided' unless value
            value.each do |addr|
              cmds << "ip virtual-router address #{addr}"
            end
          end
        end
        configure(cmds)
      end
      # rubocop:enable Metrics/MethodLength

      ##
      # The add_address method assigns one virtual IPv4 address.
      #
      # @param name [String] The name of the interface. The
      #   name argument must be the full interface name. Valid interfaces
      #   are restricted to VLAN interfaces.
      #
      # @param value [string] The virtual router address to add.
      #
      # @return [Boolean] True if the commands succeeds otherwise False.
      def add_address(name, value)
        configure(["interface #{name}", "ip virtual-router address #{value}"])
      end

      ##
      # The remove_address method removes one virtual IPv4 address.
      #
      # @param name [String] The name of the interface. The
      #   name argument must be the full interface name. Valid interfaces
      #   are restricted to VLAN interfaces.
      #
      # @param value [string] The virtual router address to remove.
      #
      # @return [Boolean] True if the commands succeeds otherwise False.
      def remove_address(name, value)
        configure(["interface #{name}",
                   "no ip virtual-router address #{value}"])
      end
    end
  end
end
