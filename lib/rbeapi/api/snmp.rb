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
  # Api is module namespace for working with the EOS command API
  module Api
    ##
    # The Snmp class provides a class implementation for working with the
    # nodes SNMP configuration entity.  This class presents an abstraction
    # of the node's snmp configuration from the running config.
    #
    # @eos_version 4.13.7M
    class Snmp < Entity
      DEFAULT_SNMP_LOCATION = ''
      DEFAULT_SNMP_CONTACT = ''
      DEFAULT_SNMP_CHASSIS_ID = ''
      DEFAULT_SNMP_SOURCE_INTERFACE = ''
      CFG_TO_STATE = { 'default' => 'default', 'no' => 'off', nil => 'on' }
      STATE_TO_CFG = { 'default' => 'default', 'on' => nil, 'off' => 'no' }

      ##
      # get returns the snmp resource Hash that represents the nodes snmp
      # configuration abstraction from the running config.
      #
      # @example
      #   {
      #     location: <string>,
      #     contact: <string>,
      #     chassis_id: <string>,
      #     source_interface: <string>
      #   }
      #
      # @return[Hash<Symbol, Object>] Returns the snmp resource as a Hash
      def get
        response = {}
        response.merge!(parse_location)
        response.merge!(parse_contact)
        response.merge!(parse_chassis_id)
        response.merge!(parse_source_interface)
        response.merge!(parse_communities)
        response.merge!(parse_notifications)
        response
      end

      ##
      # parse_location scans the running config from the node and parses
      # the snmp location value if it exists in the configuration.  If the
      # snmp location is not configure, then the DEFAULT_SNMP_LOCATION string
      # is returned.  The Hash returned by this method is merged into the
      # snmp resource Hash returned by the get method.
      #
      # @api private
      #
      # @return [Hash<Symbol,Object>] resource Hash attribute
      def parse_location
        mdata = /snmp-server location (.+)$/.match(config)
        { location: mdata.nil? ? DEFAULT_SNMP_LOCATION : mdata[1] }
      end
      private :parse_location

      ##
      # parse_contact scans the running config form the node and parses
      # the snmp contact value if it exists in the configuration.  If the
      # snmp contact is not configured, then the DEFAULT_SNMP_CONTACT value
      # is returned.  The Hash returned by this method is merged into the
      # snmp resource Hash returned by the get method.
      #
      # @api private
      #
      # @return [Hash<Symbol,Object] resource Hash attribute
      def parse_contact
        mdata = /snmp-server contact (.+)$/.match(config)
        { contact: mdata.nil? ? DEFAULT_SNMP_CONTACT : mdata[1] }
      end
      private :parse_contact

      ##
      # parse_chassis_id scans the running config from the node and parses
      # the snmp chassis id value if it exists in the configuration.  If the
      # snmp chassis id is not configured, then the DEFAULT_SNMP_CHASSIS_ID
      # value is returned.  The Hash returned by this method is intended to
      # be merged into the snmp resource Hash
      #
      # @api private
      #
      # @return [Hash<Symbol,Object>] resource Hash attribute
      def parse_chassis_id
        mdata = /snmp-server chassis-id (.+)$/.match(config)
        { chassis_id: mdata.nil? ? DEFAULT_SNMP_CHASSIS_ID : mdata[1] }
      end
      private :parse_chassis_id

      ##
      # parse_source_interface scans the running config from the node and
      # parses the snmp source interface value if it exists in the
      # configuration.  If the snmp source interface is not configured, then
      # the DEFAULT_SNMP_SOURCE_INTERFACE value is returned.  The Hash
      # returned by this method is intended to be merged into the snmmp
      # resource Hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource Hash attribute
      def parse_source_interface
        mdata = /snmp-server source-interface (.+)$/.match(config)
        { source_interface: mdata.nil? ? '' : mdata[1] }
      end
      private :parse_source_interface

      ##
      # parse_communities scans the running config from the node and parses all
      # of the configure snmp community strings.  If there are no configured
      # snmp community strings, the community value is set to an empty array.
      # The returned hash is intended to be merged into the global snmp
      # resource hash
      #
      # @api private
      #
      # @return [Hash<Hash>] resource hash attribute
      def parse_communities
        values = config.scan(/snmp-server community (\w+) (ro|rw)[ ]?(.+)?$/)
        communities = values.each_with_object({}) do |value, hsh|
          name, access, acl = value
          hsh[name] = { access: access, acl: acl }
        end
        { communities: communities }
      end
      private :parse_communities

      ##
      # parse_notifications scans the running configuration and parses all of
      # the snmp trap notifications configuration.  It is expected the trap
      # configuration is in the running config.  The returned hash is intended
      # to be merged into the resource hash
      def parse_notifications
        traps = config.scan(/(default|no)?[ ]?snmp-server enable traps (.+)$/)
        all = config.scan(/(default|no)?[ ]?snmp-server enable traps$/).first

        notifications = traps.map do |trap|
          state, name = trap
          { name: name, state: CFG_TO_STATE[state] }
        end
        notifications << { name: 'all', state: CFG_TO_STATE[all.first] }
        { notifications: notifications }
      end
      private :parse_notifications

      ##
      # set_notification configures the snmp trap notification for the
      # specified trap.  The name option accepts the snmp trap name to
      # configure or the keyword all to globally enable or disable
      # notifications.  If the optional state argument is not provided then the
      # default state is default.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   snmp-server enable traps <name>
      #   no snmp-server enable traps <name>
      #   default snmp-server enable traps <name>
      #
      # @param [String] :name The name of the trap to configure or the keyword
      #   all.  If this option is not specified, then the value of 'all' is
      #   used as the default.
      #
      # @param [String] :state The state to configure the trap notification.
      #   Valid values include 'on', 'off' or 'default'
      def set_notification(opts = {})
        name = opts[:name]
        name = nil if name == 'all'
        state = opts[:state] || 'default'
        state = STATE_TO_CFG[state]
        configure "#{state} snmp-server enable traps #{name}"
      end

      ##
      # set_location updates the snmp location value in the nodes running
      # configuration.  If enable is false, then the snmp location value is
      # negated using the no keyword.  If the default keyword is set to true,
      # then the snmp location value is defaulted using the default keyword.
      # The default parameter takes precedence over the enable keyword.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   snmp-server location <value>
      #   no snmp-server location
      #   default snmp-server location
      #
      # @param [Hash] opts The configuration parameters
      #
      # @option opts [string] :value The snmp location value to configure
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option opts [Boolean] :default Configure the snmp location value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_location(opts = {})
        cmd = command_builder('snmp-server location', opts)
        configure(cmd)
      end

      ##
      # set_contact updates the snmp contact value in the nodes running
      # configuration.  If enable is false in the opts Hash then
      # the snmp contact value is negated using the no keyword.  If the
      # default keyword is set to true, then the snmp contact value is
      # defaulted using the default keyword.  The default parameter takes
      # precedence over the enable keyword.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   snmp-server contact <value>
      #   no snmp-server contact
      #   default snmp-server contact
      #
      # @param [Hash] opts The configuration parameters
      #
      # @option opts [string] :value The snmp contact value to configure
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option opts [Boolean] :default Configures the snmp contact value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_contact(opts = {})
        cmd = command_builder('snmp-server contact', opts)
        configure(cmd)
      end

      ##
      # set_chassis_id updates the snmp chassis id value in the nodes
      # running configuration.  If enable is false in the opts
      # Hash then the snmp chassis id value is negated using the no
      # keyword.  If the default keyword is set to true, then the snmp
      # chassis id value is defaulted using the default keyword.  The default
      # keyword takes precedence over the enable keyword.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   snmp-server chassis-id <value>
      #   no snmp-server chassis-id
      #   default snmp-server chassis-id
      #
      # @param [Hash] opts The configuration parameters
      #
      # @option opts [string] :value The snmp chassis id value to configure
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option opts [Boolean] :default Configures the snmp chassis id value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_chassis_id(opts = {})
        cmd = command_builder('snmp-server chassis-id', opts)
        configure(cmd)
      end

      ##
      # set_source_interface updates the snmp source interface value in the
      # nodes running configuration.  If enable is false in the opts
      # Hash then the snmp source interface is negated using the no keyword.
      # If the default keyword is set to true, then the snmp source interface
      # value is defaulted using the default keyword.  The default keyword
      # takes precedence over the enable keyword.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   snmp-server source-interface <value>
      #   no snmp-server source-interface
      #   default snmp-server source-interface
      #
      # @param [Hash] opts The configuration parameters
      #
      # @option opts [string] :value The snmp source interface value to
      #   configure.  This method will not ensure the interface is present
      #   in the configuration
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default Configures the snmp source interface
      #   value using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_source_interface(opts = {})
        cmd = command_builder('snmp-server source-interface', opts)
        configure(cmd)
      end

      ##
      # add_community adds a new snmp community to the nodes running
      # configuration.  This function is a convenience function that passes the
      # message to set_community_access.
      #
      # @see set_community_access
      #
      # @param [String] :name The name of the snmp community to add to the
      #   nodes running configuration.
      #
      # @param [String] :access Specifies the access level to assign to the
      #   new snmp community.  Valid values are 'rw' or 'ro'
      #
      # @return [Boolean] returns true if the command completed successfully
      def add_community(name, access = 'ro')
        set_community_access(name, access)
      end

      ##
      # remove_community removes the specified community from the nodes running
      # configuration.  If the specified name is not configured, this method
      # will still return successfully.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   no snmp-server community <name>
      #
      # @param [String] :name The name of the snmp community to add to the
      #   nodes running configuration.
      #
      # @return [Boolean] returns true if the command completed successfully
      def remove_community(name)
        configure "no snmp-server community #{name}"
      end

      ##
      # set_community_acl configures the acl to apply to the specified
      # community name.  When enable is true, it will remove the
      # the named community and then add the new acl entry.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   no snmp-server <name> [ro|rw] <value>
      #   snmp-server <name> [ro|rw] <value>
      #
      # @param [String] :name The name of the snmp community to add to the
      #   nodes running configuration.
      #
      # @param [Hash] opts The configuration parameters
      #
      # @option opts [String] :value The name of the acl to apply to the snmp
      #   community in the nodes config. If nil, then the community name
      #   allows access to all objects.
      # @option opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default Configure the snmp community name
      #   using the default keyword. Default takes precedence over enable.
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_community_acl(name, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts.fetch(:default, false)
        # Default is same as negate for this command
        enable = default ? false : enable
        communities = parse_communities[:communities]
        access = communities[name][:access] if communities.include?(name)
        cmds = ["no snmp-server community #{name}"]
        cmds << "snmp-server community #{name} #{access} #{value}" if enable
        configure cmds
      end

      def set_community_access(name, access)
        configure "snmp-server community #{name} #{access}"
      end
    end
  end
end
