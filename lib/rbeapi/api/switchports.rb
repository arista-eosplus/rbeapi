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
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Api is module namesapce for working with the EOS command API
  module Api
    ##
    # The Switchport class provides a base class instance for working with
    # logical layer-2 interfaces.
    #
    class Switchports < Entity
      ##
      # Retrieves the properies for a logical switchport from the
      # running-config using eAPI
      #
      # Example
      #   {
      #     "name": <String>,
      #     "mode": [access, trunk],
      #     "trunk_allowed_vlans": array<strings>
      #     "trunk_native_vlan": <Integer>,
      #     "access_vlan": <Integer>
      #   }
      #
      # @param [String] name The full name of the interface to get.  The
      #   interface name must be the full interface (ie Ethernet, not Et)
      #
      # @return [Hash] a hash that includes the switchport properties
      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil if /no\sswitchport$/ =~ config

        response = {}
        response.merge!(parse_mode(config))
        response.merge!(parse_access_vlan(config))
        response.merge!(parse_trunk_native_vlan(config))
        response.merge!(parse_trunk_allowed_vlans(config))
        response
      end

      def parse_mode(config)
        mdata = /(?<=\s{3}switchport\smode\s)(.+)$/.match(config)
        { mode: mdata[1] }
      end

      def parse_access_vlan(config)
        mdata = /(?<=access\svlan\s)(.+)$/.match(config)
        { access_vlan: mdata[1] }
      end

      def parse_trunk_native_vlan(config)
        mdata = /(?<=trunk\snative\svlan\s)(.+)$/.match(config)
        { trunk_native_vlan: mdata[1] }
      end

      def parse_trunk_allowed_vlans(config)
        mdata = /(?<=trunk\sallowed\svlan\s)(.+)$/.match(config)
        return { trunk_allowed_vlans: [] } unless mdata[1] != 'none'
        vlans = mdata[1].split(',')
        values = vlans.each_with_object([]) do |vlan, arry|
          if /-/ !~ vlan
            arry << vlan.to_i
          else
            range_start, range_end = vlan.split('-')
            arry.push(*Array(range_start.to_i..range_end.to_i))
          end
        end
        { trunk_allowed_vlans: values }
      end

      ##
      # Retrieves all switchport interfaces from the running-config
      #
      # @return [Array] an array of switchport hashes
      def getall
        interfaces = config.scan(/(?<=^interface\s)([Et|Po].+)$/)
        interfaces.each_with_object({}) do |port, hsh|
          cfg = get port.first
          hsh[port.first] = cfg if cfg
        end
      end

      ##
      # Creates a new logical switchport interface in EOS
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def create(name)
        configure ["interface #{name}", 'no ip address', 'switchport']
      end

      ##
      # Deletes a logical switchport interface from the running-config
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def delete(name)
        configure ["interface #{name}", 'no switchport']
      end

      ##
      # Defaults a logical switchport interface in the running-config
      #
      # @param [String] name The name of the logical interface
      #
      # @return [Boolean] True if it succeeds otherwise False
      def default(name)
        configure ["interface #{name}", 'default switchport']
      end

      ##
      # Configures the switchport mode for the specified interafce.  Valid
      # modes are access (default) or trunk
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value to set the mode to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_mode(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport mode'
        when false
          if value.nil?
            cmds << 'no switchport mode'
          else
            cmds << "switchport mode #{value}"
          end
        end
        configure(cmds)
      end

      ##
      # set_trunk_allowed_vlans configures the list of vlan ids that are
      # allowed on the specified trunk port.  If the value option is not
      # provided, then the allowed trunks is configured using the no keyword.
      # If the default keyword is provied then the allowed trunks is configured
      # using the default keywork  The default optio takes precedence over the
      # value option if both are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   switchport trunk allowed vlan add <value>
      #   no switchport trunk allowed vlan
      #   default switchport trunk allowed vlan
      #
      # @option [Array] :value The list of vlan ids to configure on the
      #   switchport to be allowed.  This value must be an array of valid vlan
      #   ids
      #
      # @option [Boolean] :default Configures the switchport trunk allowed
      #     vlans command using the default keyword
      #
      # @return [Boolean] returns true if the commands complete successfully
      def set_trunk_allowed_vlans(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        fail ArgumentError, 'value must be an Array' unless value.is_a?(Array)

        value = value.map(&:inspect).join(',') if value

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport trunk allowed vlan'
        when false
          if value.nil?
            cmds << 'no switchport trunk allowed vlan'
          else
            cmds << 'switchport trunk allowed vlan none'
            cmds << "switchport trunk allowed vlan #{value}"
          end
        end
        configure(cmds)
      end

      ##
      # Configures the trunk port native vlan for the specified interface.
      # This value is only valid if the switchport mode is configure as
      # trunk.
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value of the trunk native vlan
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_trunk_native_vlan(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport trunk native vlan'
        when false
          if value.nil?
            cmds << 'no switchport trunk native vlan'
          else
            cmds << "switchport trunk native vlan #{value}"
          end
        end
        configure(cmds)
      end

      ##
      # Configures the access port vlan for the specified interface.
      # This value is only valid if the switchport mode is configure
      # in access mode.
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for the interface
      # @option opts [string] :value The value of the access vlan
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_access_vlan(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default switchport access vlan'
        when false
          if value.nil?
            cmds << 'no switchport access vlan'
          else
            cmds << "switchport access vlan #{value}"
          end
        end
        configure(cmds)
      end
    end
  end
end
