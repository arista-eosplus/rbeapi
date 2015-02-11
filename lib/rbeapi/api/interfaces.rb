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
require 'rbeapi/utils'

module Rbeapi

  module Api

    class Interfaces < Entity

      METHODS = [:create, :delete, :default]

      def initialize(node)
        super(node)
        @instances = {}
      end

      def get(name)
        get_instance(name).get(name)
      end

      def getall
        interfaces = config.scan(/(?<=^interface\s).+$/)

        interfaces.each_with_object({}) do |name, hsh|
          data = get(name)
          hsh[name] = data if data
        end
      end

      def get_instance(name)
        name = name[0,2].upcase
        case name
        when 'ET'
          cls = 'Rbeapi::Api::EthernetInterface'
        when 'PO'
          cls = 'Rbeapi::Api::PortchannelInterface'
        when 'VX'
          cls = 'Rbeapi::Api::VxlanInterface'
        else
          cls = 'Rbeapi::Api::BaseInterface'
        end

        return @instances[name] if @instances.include?(cls)
        instance = Rbeapi::Utils.class_from_string(cls).new(@node)
        @instances[name] = instance
        instance
      end

      def method_missing(method_name, *args, &block)
        if method_name.to_s =~ /set_(.*)/ || METHODS.include?(method_name)
          instance = get_instance(args[0])
          instance.send(method_name.to_sym, *args, &block)
        end
      end

      def respond_to?(method_name, name = nil)
        return super unless name
        instance = get_instance(name)
        instance.respond_to?(method_name) || super
      end

    end

    ##
    # The BaseInterface class extends Entity and provides an implementation
    # that is common to all interfaces configured in EOS.
    class BaseInterface < Entity

      ##
      # Returns the base interface properties common to all interfaces and
      # sets the type to 'generic'.
      #
      # @example
      #   {
      #     "name": <string>,
      #     "type": 'generic',
      #     "description": <string>,
      #     "shutdown":  [true, false]
      #   }
      #
      # @param [String] :name The name of the interface to return from the
      #   running-configuration
      #
      # @return [nil, Hash<String, String> Returns a hash of the interface
      #   properties if the interface name was found in the running
      #   configuration.  If the interface was not found, nil is returned
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = { 'name' => name, 'type' => 'generic' }
        response['shutdown'] = /\s{3}(no\sshutdown)$/ !~ config

        mdata = /(?<=\s{3}description\s)(.+)$/.match(config)
        response['description'] = mdata.nil? ? '' : mdata[1]

        response
      end

      ##
      # Creates an interface on the node in the running config
      #
      # @param [String] :name The name of the interface to create
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def create(name)
        configure("interface #{name}")
      end

      ##
      # Deletes the interface configuration from the nodes operational
      # (running) config
      #
      # @param [String] :name The name of the interface to remove from the
      #  running config
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def delete(name)
        configure("no interface #{name}")
      end

      ##
      # Configures the interface using the default configuration command
      # which will cause all interface configuratin settings to be reset
      # to default values
      #
      # @param [String] :name The name of the interface to apply the default
      #   configuration to
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def default(name)
        configure("default interface #{name}")
      end

      ##
      # Configures the interface description for the specified interface
      #
      # @param [String] :name The name of the interface to apply the
      #   configuration values to
      # @param [Hash] :opts Optional keyword arguments
      # @option :opts [String] :value The value to assign to the interface
      #   description in the configuration.  If this value is nil and default
      #   is false, then the description command is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   description configuration command should be defaulted.  The value
      #   of this option has higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_description(name, opts = {})
        value = opts[:value]
        value = nil if value.empty?
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default description'
        when false
          cmds << (value.nil? ? 'no description' : "description #{value}")
        end
        configure(cmds)
      end

      ##
      # Conifgures the adminstrative state of the specified interfaces
      #
      # @param [String] :name The name of the interface to apply the
      #   configuration values to
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [Boolean] :value Configures the interface to be
      #   administratively disabled (shutdown) if the value is true otherwise
      #   configures the adminstrative state to enabled (no shutdown).  If
      #   the value is nil then the shutdown command is negated.
      # @option :opts [Boolean] :default Specifies whether or not the
      #   shutdown command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_shutdown(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default shutdown'
        when false
          cmds << (value ? 'shutdown' : 'no shutdown')
        end
        configure(cmds)
      end
    end

    class EthernetInterface < BaseInterface

      ##
      # Returns the Ethernet interface as a Ruby hash of key/value pairs that
      # represent the interface configuration from the node.  This method
      # extends the get method from the BaseInterface and adds the Ethernet
      # specific attributes
      #
      # @example
      #   {
      #     "name": <string>,
      #     "type": 'ethernet',
      #     "description": <string>
      #     "shutdown": [true, false],
      #     "sflow": [true, false],
      #     "flowcontrol_send": [on, off],
      #     "flowcontrol_receive": [on, off]
      #   }
      #
      # @param [String] :name The name of the interface to return the
      #   configuration values for.  This argument must be the full interface
      #   identifier
      #
      # @return [nil, Hash<String, String>] Returns a Ruby Hash object that
      #   represents the interface configuration.  If the name argument
      #   is not found in the node's configuration then nil is returned
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response.update({ 'name' => name, 'type' => 'ethernet' })

        sflow = /no sflow enable/ =~ config
        response['sflow'] = sflow.nil?

        mdata = /(?<=\s{3}flowcontrol\ssend\s)(?<value>.+)$/.match(config)
        response['flowcontrol_send'] = mdata.nil? ? 'off' : mdata[1]

        mdata = /(?<=\s{3}flowcontrol\sreceive\s)(?<value>.+)$/.match(config)
        response['flowcontrol_receive'] = mdata.nil? ? 'off' : mdata[1]

        response
      end

      ##
      # Overrides the default behavior of the create method from the
      # BaseInterface class to raise an error because Ethernet interface
      # creation is not supported.
      #
      # @param [String] :name The name of the interface
      #
      # @raise [NotImplementedError] Creation of physical Ethernet interfaces
      #   is not supported
      def create(name)
        raise NotImplementedError, 'creating Ethernet interfaces is '\
              'not supported'
      end

      ##
      # Overrides the default behavior of the delete method from the
      # BaseInterface class to raise an error because Ethernet interface
      # deletion is not supported.
      #
      # @param [String] :name The name of the interface
      #
      # @raise [NotImplementedError] Deletion of physical Ethernet interfaces
      #   is not supported
      def delete(name)
        raise NotImplementedError, 'deleting Ethernet interfaces is '\
              'not supported'
      end

      ##
      # Configures sflow support for the specified interface
      #
      # @param [String] :name The name of the Ethernet interface to enable or
      #   disable sflow support on
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [Boolean] :value True to enable sflow support on the
      #   interface or False to disable sflow support.  If no value is provided
      #   then the value is negated (set to False)
      # @option :opts [Boolean] :default Specifies whether or not the
      #   sflow command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_sflow(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default sflow'
        when false
          cmds << (value ? 'sflow enable' : 'no sflow enable')
        end
        configure(cmds)
      end

      ##
      # Configures flowcontrol support for the specified interface
      #
      # @param [String] :name The name of the Ethernet interface to configure
      # @param [String] :direction The flowcontrol direction (send or receive)
      #   to configure for the interface
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting to in the configuration.  Valid values are
      #   on and off.  If the value is not provided and default is false
      #   then the flowcontrol setting is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   flowcontrol command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_flowcontrol(name, direction, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        commands = ["interface #{name}"]
        case default
        when true
          commands << "default flowcontrol #{direction}"
        when false
          commands << (value.nil? ? "no flowcontrol #{direction}" :
                                    "flowcontrol #{direction} #{value}")
        end
        configure(commands)
      end

      ##
      # Configures the flowcontrol send value for the specified Ethernet
      # interface
      #
      # @param [String] :name The name of the Ethernet interface to configure
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting to in the configuration.  Valid values are
      #   on and off.  If the value is not provided and default is false
      #   then the flowcontrol setting is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   flowcontrol command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_flowcontrol_send(name, opts = {})
        set_flowcontrol(name, 'send', opts)
      end

      ##
      # Configures the flowcontrol receive value for the specified Ethernet
      # interface
      #
      # @param [String] :name The name of the Ethernet interface to configure
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting to in the configuration.  Valid values are
      #   on and off.  If the value is not provided and default is false
      #   then the flowcontrol setting is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   flowcontrol command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_flowcontrol_receive(name, opts = {})
        set_flowcontrol(name, 'receive', opts)
      end
    end

    class PortchannelInterface < BaseInterface

      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response.update({'name' => name, 'type' => 'portchannel'})

        response['members'] = get_members(name)
        response['lacp_mode'] = get_lacp_mode(name)

        mdata = /(?<=\s{3}port-channel\smin-links\s)(.+)$/.match(config)
        response['minimum_links'] = mdata.nil? ? '0' : mdata[1]

        mdata = /(?<=\s{3}lacp\sfallback\stimeout\s)(.+)$/.match(config)
        response['lacp_timeout'] = mdata.nil? ? '' : mdata[1]

        response
      end

      def get_members(name)
        grpid = name.scan(/(?<=Port-Channel)\d+/)[0]
        command = "show port-channel #{grpid} all-ports"
        config = node.enable(command, format: 'text')
        config.first[:result]['output'].scan(/Ethernet[\d\/]*/)
      end

      def get_lacp_mode(name)
        members = get_members(name)
        return 'on' unless members
        config = get_block("^interface #{members.first}")
        mdata = /channel-group\s\d+\smode\s(.+)/.match(config)
        mdata.nil? ? 'on' : mdata[1]
      end

      def set_minimum_links(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default port-channel min-links'
        when false
          cmds << (value ? "port-channel min-links #{value}" : \
                           'no port-channel min-links')
        end
        configure(cmds)
      end

      def set_members(name, members)
        current_members = Set.new get_members(name)
        members = Set.new members

        # remove members from the current port-channel interface
        current_members.difference(members).each do |intf|
          result = remove_member(name, intf)
          return false unless result
        end

        # add new member interfaces to the port-channel
        members.difference(current_members).each do |intf|
          result = add_member(name, intf)
          return false unless result
        end

        return true
      end

      def add_member(name, member)
        lacp = get_lacp_mode(name)
        grpid = /(\d+)/.match(name)[0]
        configure ["interface #{member}", "channel-group #{grpid} mode #{lacp}"]
      end

      def remove_member(name, member)
        grpid = /(\d+)/.match(name)[0]
        configure ["interface #{member}", "no channel-group #{grpid}"]
      end

      def set_lacp_mode(name, mode)
        return false unless %w(on passive active).include?(mode)
        grpid = /(\d+)/.match(name)[0]

        remove_commands = []
        add_commands = []

        get_members(name).each do |member|
          remove_commands << "interface #{member}"
          remove_commands << "no channel-group #{grpid}"
          add_commands << "interface #{member}"
          add_commands << "channel-group #{grpid} mode #{mode}"
        end
        configure remove_commands + add_commands
      end

      def set_lacp_fallback(name, opts = {})
      end

      def set_lacp_timeout(name, opts = {})
      end

    end

    class VxlanInterface < BaseInterface

      ##
      # Returns the Vxlan interface configuration as a Ruby hash of key/value
      # pairs from the nodes running configuration. This method extends the
      # BaseInterface get method and adds the Vxlan specific attributes to
      # the hash
      #
      # @example
      #   {
      #     "name": <string>,
      #     "type": 'vxlan',
      #     "description": <string>,
      #     "shutdown": [true, false],
      #     "source_interface": <string>,
      #     "multicast_group": <string>
      #   }
      #
      # @param [String] :name The interface name to return from the nodes
      #   configuration.  This optional parameter defaults to Vxlan1
      #
      # @return [nil, Hash<String, String>] Returns the interface configuration
      #   as a Ruby hash object.   If the provided interface name is not found
      #   then this method will return nil
      def get(name = 'Vxlan1')
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response.update({ 'name' => name, 'type' => 'vxlan' })

        mdata = /(?<=\s{3}vxlan\ssource-interface\s)(.+)$/.match(config)
        response['source_interface'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=\s{3}vxlan\smulticast-group\s)(.+)$/.match(config)
        response['multicast_group'] = mdata.nil? ? '' : mdata[0]

        response
      end

      ##
      # Configures the vxlan source-interface to the specified value.  This
      # parameter should be a the interface identifier of the interface to act
      # as the source for all Vxlan traffic
      #
      # @param [String] :name The name of the interface to apply the
      #   configuration values to
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [String] :value Configures the vxlan source-interface to
      #   the spcified value.  If no value is provided and the
      #   default keyword is not specified then the value is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   multicast-group command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_source_interface(name = 'Vxlan1', opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default vxlan source-interface'
        when false
          cmds << (value ? "vxlan source-interface #{value}" : \
                           'no vxlan source-interface')
        end
        configure(cmds)
      end

      ##
      # Configures the vxlan multcast-group flood address to the specified
      # value.  The value should be a valid multicast address
      #
      # @param [String] :name The name of the interface to apply the
      #   configuration values to
      # @param [Hash] :opt Optional keyword arguments
      # @option :opts [String] :value Configures the mutlicast-group flood
      #   address to the specified value.  If no value is provided and the
      #   default keyword is not specified then the value is negated
      # @option :opts [Boolean] :default Specifies whether or not the
      #   multicast-group command is configured as default.  The value of this
      #   option has a higher precedence than :value
      #
      # @return [Boolean] This method returns true if the commands were
      #   successful otherwise it returns false
      def set_multicast_group(name = 'Vxlan1', opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default vxlan multicast-group'
        when false
          cmds << (value ? "vxlan multicast-group #{value}" : \
                           'no vxlan multtcast-group')
        end
        configure(cmds)
      end
    end
  end
end
