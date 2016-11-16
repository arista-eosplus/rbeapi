#
# Copyright (c) 2014,2015 Arista Networks, Inc.
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
    # The Switchport class provides a base class instance for working with
    # logical layer-2 interfaces.
    #
    class Switchports < Entity
      ##
      # Retrieves the properties for a logical switchport from the
      # running-config using eAPI.
      #
      # Example
      #   {
      #     "name": <String>,
      #     "mode": [access, trunk],
      #     "trunk_allowed_vlans": array<strings>
      #     "trunk_native_vlan": <Integer>,
      #     "access_vlan": <Integer>,
      #     "trunk_groups": array<strings>
      #   }
      #
      # @param name [String] The full name of the interface to get.  The
      #   interface name must be the full interface (ie Ethernet, not Et).
      #
      # @return [Hash] Returns a hash that includes the switchport properties.
      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil if /no\sswitchport$/ =~ config

        response = {}
        response.merge!(parse_mode(config))
        response.merge!(parse_access_vlan(config))
        response.merge!(parse_trunk_native_vlan(config))
        response.merge!(parse_trunk_allowed_vlans(config))
        response.merge!(parse_trunk_groups(config))
        response
      end

      ##
      # parse_mode parses switchport mode from the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_mode(config)
        mdata = /(?<=\s{3}switchport\smode\s)(.+)$/.match(config)
        return { mode: [] } unless defined? mdata[1]
        { mode: mdata[1] }
      end
      private :parse_mode

      ##
      # parse_access_vlan parses access vlan from the provided
      #   config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_access_vlan(config)
        mdata = /(?<=access\svlan\s)(.+)$/.match(config)
        return { access_vlan: [] } unless defined? mdata[1]
        { access_vlan: mdata[1] }
      end
      private :parse_access_vlan

      ##
      # parse_trunk_native_vlan parses trunk native vlan from
      #   the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_trunk_native_vlan(config)
        mdata = /(?<=trunk\snative\svlan\s)(.+)$/.match(config)
        return { trunk_native_vlan: [] } unless defined? mdata[1]
        { trunk_native_vlan: mdata[1] }
      end
      private :parse_trunk_native_vlan

      ##
      # parse_trunk_allowed_vlans parses trunk allowed vlan from
      #   the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_trunk_allowed_vlans(config)
        mdata = /(?<=trunk\sallowed\svlan\s)(.+)$/.match(config)
        return { trunk_allowed_vlans: [] } unless mdata[1] != 'none'
        vlans = mdata[1].split(',')
        values = vlans.each_with_object([]) do |vlan, arry|
          arry << vlan.to_s
        end
        { trunk_allowed_vlans: values }
      end
      private :parse_trunk_allowed_vlans

      ##
      # parse_trunk_groups parses trunk group values from the
      #   provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_trunk_groups(config)
        mdata = config.scan(/(?<=trunk\sgroup\s)(.+)$/)
        return { trunk_group: [] } unless defined? mdata[1]
        mdata = mdata.flatten unless mdata.empty?
        { trunk_groups: mdata }
      end
      private :parse_trunk_groups

      ##
      # Retrieves all switchport interfaces from the running-config.
      #
      # @example
      #   {
      #     <name>: {
      #       mode: <string>,
      #       access_vlan: <string>,
      #       trunk_native_vlan: <string>,
      #       trunk_allowed_vlans: <array>,
      #       trunk_groups: <array>
      #     },
      #     <name>: {
      #       mode: <string>,
      #       access_vlan: <string>,
      #       trunk_native_vlan: <string>,
      #       trunk_allowed_vlans: <array>,
      #       trunk_groups: <array>
      #     },
      #     ...
      #   }
      #
      # @return [Array] Returns an array of switchport hashes.
      def getall
        interfaces = config.scan(/(?<=^interface\s)([Et|Po].+)$/)
        interfaces.each_with_object({}) do |port, hsh|
          cfg = get port.first
          hsh[port.first] = cfg if cfg
        end
      end

      ##
      # Creates a new logical switchport interface in EOS.
      #
      # @param name [String] The name of the logical interface.
      #
      # @return [Boolean] Returns True if it succeeds otherwise False.
      def create(name)
        configure ["interface #{name}", 'no ip address', 'switchport']
      end

      ##
      # Deletes a logical switchport interface from the running-config.
      #
      # @param name [String] The name of the logical interface.
      #
      # @return [Boolean] Returns True if it succeeds otherwise False.
      def delete(name)
        configure ["interface #{name}", 'no switchport']
      end

      ##
      # Defaults a logical switchport interface in the running-config.
      #
      # @param name [String] The name of the logical interface.
      #
      # @return [Boolean] Returns True if it succeeds otherwise False.
      def default(name)
        configure ["interface #{name}", 'default switchport']
      end

      ##
      # Configures the switchport mode for the specified interface.
      #
      # @param name [String] The name of the interface to configure.
      #
      # @param opts [Hash] The configuration parameters for the interface.
      #
      # @option opts value [string] The value to set the mode to.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default.
      #
      # @return [Boolean] Returns True if the commands succeed otherwise False.
      def set_mode(name, opts = {})
        cmd = command_builder('switchport mode', opts)
        configure_interface(name, cmd)
      end

      ##
      # set_trunk_allowed_vlans configures the list of vlan ids that are
      # allowed on the specified trunk port. If the enable option is set to
      # false, then the allowed trunks is configured using the no keyword.
      # If the default keyword is provided then the allowed trunks is configured
      # using the default keyword. The default option takes precedence over the
      # enable option if both are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   switchport trunk allowed vlan add <value>
      #   no switchport trunk allowed vlan
      #   default switchport trunk allowed vlan
      #
      # @param name [String] The name of the interface to configure.
      #
      # @param opts [Hash] The configuration parameters for the interface.
      #
      # @option opts value [Array] The list of vlan ids to configure on the
      #   switchport to be allowed. This value must be an array of valid vlan
      #   ids or vlan ranges.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option default [Boolean] Configures the switchport trunk allowed
      #     vlans command using the default keyword. Default takes precedence
      #     over enable.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def set_trunk_allowed_vlans(name, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        if value
          raise ArgumentError, 'value must be an Array' unless value.is_a?(Array)
          value = value.map(&:inspect).join(',').tr('"', '')
        end

        case default
        when true
          cmds = 'default switchport trunk allowed vlan'
        when false
          cmds = if !enable
                   'no switchport trunk allowed vlan'
                 else
                   ["switchport trunk allowed vlan #{value}"]
                 end
        end
        configure_interface(name, cmds)
      end

      ##
      # Configures the trunk port native vlan for the specified interface.
      # This value is only valid if the switchport mode is configure as
      # trunk.
      #
      # @param name [String] The name of the interface to configure.
      #
      # @param opts [Hash] The configuration parameters for the interface.
      #
      # @option opts value [string] The value of the trunk native vlan.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default.
      #   Default takes precedence over enable.
      #
      # @return [Boolean] Returns True if the commands succeed otherwise False.
      def set_trunk_native_vlan(name, opts = {})
        cmd = command_builder('switchport trunk native vlan', opts)
        configure_interface(name, cmd)
      end

      ##
      # Configures the access port vlan for the specified interface.
      # This value is only valid if the switchport mode is configure
      # in access mode.
      #
      # @param name [String] The name of the interface to configure.
      #
      # @param opts [Hash] The configuration parameters for the interface.
      #
      # @option opts value [string] The value of the access vlan.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default
      #   Default takes precedence over enable.
      #
      # @return [Boolean] Returns True if the commands succeed otherwise False.
      def set_access_vlan(name, opts = {})
        cmd = command_builder('switchport access vlan', opts)
        configure_interface(name, cmd)
      end

      ##
      # Configures the trunk group vlans for the specified interface.
      # Trunk groups not currently set are added and trunk groups
      # currently configured but not in the passed in value array are removed.
      #
      # @param name [String] The name of the interface to configure.
      #
      # @param opts [Hash] The configuration parameters for the interface.
      #
      # @option opts value [string] Set of values to configure the trunk group.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] The value should be set to default
      #   Default takes precedence over enable.
      #
      # @return [Boolean] Returns True if the commands succeed otherwise False.
      def set_trunk_groups(name, opts = {})
        default = opts.fetch(:default, false)
        if default
          return configure_interface(name, 'default switchport trunk group')
        end

        enable = opts.fetch(:enable, true)
        unless enable
          return configure_interface(name, 'no switchport trunk group')
        end

        value = opts.fetch(:value, [])
        raise ArgumentError, 'value must be an Array' unless value.is_a?(Array)

        value = Set.new value
        current_value = Set.new get(name)[:trunk_groups]

        cmds = []
        # Add trunk groups that are not currently in the list.
        value.difference(current_value).each do |group|
          cmds << "switchport trunk group #{group}"
        end

        # Remove trunk groups that are not in the new list.
        current_value.difference(value).each do |group|
          cmds << "no switchport trunk group #{group}"
        end
        configure_interface(name, cmds) unless cmds.empty?
      end
    end
  end
end
