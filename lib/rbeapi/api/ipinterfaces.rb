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
    #
    # The Ipinterface class provides an instance for managing logical
    # IP interfaces configured using eAPI.
    class Ipinterfaces < Entity

      DEFAULT_ADDRESS = ''

      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil if /\s{3}switchport$/ =~ config

        response = {}
        response.merge!(parse_address(config))
        response.merge!(parse_mtu(config))
        response.merge!(parse_helper_addresses(config))
        response
      end

      def parse_address(config)
        mdata = /(?<=^\s{3}ip\saddress\s)(.+)$/.match(config)
        { address: mdata.nil? ? DEFAULT_ADDRESS : mdata[1] }
      end

      def parse_mtu(config)
        mdata = /(?<=mtu\s)(\d+)$/.match(config)
        { mtu: mdata.nil? ? '': mdata[1] }
      end

      def parse_helper_addresses(config)
        helpers = config.scan(/(?<=\s{3}ip\shelper-address\s).+$/)
        { helper_addresses: helpers }
      end

      ##
      # Retrieves all logical IP interfaces from the running-configuration
      # and returns all instances
      #
      # Example:
      #   {
      #     "Ethernet1": {
      #       "address" => "1.2.3.4/5",
      #       "mtu" => "1500",
      #       "helper_addresses" => ["5.6.7.8", "9.10.11.12"]
      #     },
      #     "Ethernet2": {...}
      #   }
      #
      # @return [Hash] all IP interfaces found in the running-config
      def getall
        interfaces = config.scan(/(?<=^interface\s).+/)
        interfaces.each_with_object({}) do |name, hsh|
          values = get name
          hsh[name] = values if values
        end
      end

      ##
      # Create a new logical IP interface in the running-config
      #
      # @param [String] name The name of the interface
      #
      # @return [Boolean] True if the create succeeds otherwise False
      def create(name)
        configure(["interface #{name}", 'no switchport'])
      end

      ##
      # Deletes a logical IP interface from the running-config
      #
      # @param [String] name The name of the interface
      #
      # @return [Boolean] True if the create succeeds otherwise False
      def delete(name)
        configure(["interface #{name}", 'no ip address', 'switchport'])
      end

      ##
      ## Configures the IP address and mask length for the interface
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the address to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_address(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default ip address'
        when false
          cmds << (value.nil? ? 'no ip address' : "ip address #{value}")
        end
        configure cmds
      end

      ##
      ## Configures the MTU value for the interface
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the MTU to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_mtu(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default mtu'
        when false
          cmds << (value.nil? ? 'no mtu' : "mtu #{value}")
        end
        configure cmds
      end

      ##
      ## Configures ip helper addresses for the interface
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @param [opts] [Array] :value list of addresses to configure as
      #   helper address on the specified interface
      # @option opts [Boolean] :default The value should be set to default
      def set_helper_addresses(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default ip helper-address'
        when false
          if value.nil?
            cmds << 'no ip helper-address'
          else
            cmds << 'default ip helper-address'
            value.each { |addr| cmds << "ip helper-address #{addr}" }
          end
        end
        configure cmds
      end
    end
  end
end
