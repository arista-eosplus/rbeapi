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

      DEFAULT_INTF_DESCRIPTION = ''

      ##
      # get returns the specified interface resource hash that represents the
      # node's current interface configuration.   The BaseInterface class
      # provides all the set of attributres that are common to all interfaces
      # in EOS.  This method will return an interface type of generic
      #
      # @example
      #   {
      #     name: <string>
      #     type: 'generic'
      #     description: <string>
      #     shutdown: [true, false]
      #   }
      #
      # @param [String] :name The name of the interface to return from the
      #   running-configuration
      #
      # @return [nil, Hash<String, Object>] Returns a hash of the interface
      #   properties if the interface name was found in the running
      #   configuration.  If the interface was not found, nil is returned
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = { name: name, type: 'generic' }
        response.merge!(parse_description(config))
        response.merge!(parse_shutdown(config))
        response
      end

      ##
      # parse_description scans the provided configuration block and parses
      # the description value if it exists in the cofiguration.  If the
      # description value is not configured, then the DEFALT_INTF_DESCRIPTION
      # value is returned.  The hash returned by this method is inteded to be
      # merged into the interface resource hash returned by the get method.
      #
      # @api private
      #
      # @eturn [Hash<Symbol, Object>] resource hash attribute
      def parse_description(config)
        mdata = /^\s{3}description\s(.+)$/.match(config)
        { description: mdata.nil? ? DEFAULT_INTF_DESCRIPTION : mdata[1] }
      end
      private :parse_description

      ##
      # parse_shutdown scans the provided configuration block and parses
      # the shutdown value.  If the shutdown value is configured then true
      # is returned as its value otherwise false is returned.  The hash
      # returned by this method is intended to be merged into the interface
      # ressource hash returned by the get method.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_shutdown(config)
        value = /no shutdown/ =~ config
        { shutdown: value.nil?  }
      end
      private :parse_shutdown

      ##
      # create will create a new interface resource in the node's current
      # configuration with the specified interface name.  If the create
      # method is called and the interface already exists, this method will
      # return successful
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <value>
      #
      # @param [String] :value The interface name to create on the node.  The
      #   interface name must be the full interface identifier (ie Loopback,
      #   not Lo)
      #
      # @return [Boolean] returns true if the command completed succesfully
      def create(value)
        configure("interface #{value}")
      end

      ##
      # delete will delete an existing interface resource in the node's
      # current configuration with the specified interface name.  If the
      # delete method is called and interface does not exist, this method
      # will return successful
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   no interface <value>
      #
      # @param [String] :value The interface name to delete from the node.
      #   The interface name must be the full interface identifier
      #   (ie Loopback, no Lo)
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(value)
        configure("no interface #{value}")
      end

      ##
      # default will configure the interface using the default keyword.  For
      # virtual interfaces this is equivalent to deleting the interface. For
      # physical interfaces, the entire interface configuration will be set
      # to defaults.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   default interface <value>
      #
      # @param [String] :value The interface name to default in the node.  The
      #   interface name must be the full interface identifier (ie Loopback,
      #   not Lo)
      #
      # @return [Boolean] returns true if the command completed successfully
      def default(value)
        configure("default interface #{value}")
      end

      ##
      # set_description configures the description value for the specified
      # interface name in the nodes running configuration.  If the value is
      # not provided in the opts keyword hash then the description value is
      # negated using the no keyword.  If the default keyword is set to
      # true, then the description value is defaulted using the default
      # keyword.  The default keyword takes precedence over the value
      # keyword if both are provided.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     description <value>
      #     no description
      #     default description
      #
      # @param [String] :name The interface name to apply the configuration
      #   to.  The name value must be the full interface identifier
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configure the description
      #   to in the node's configuration.
      #
      # @option :opts [Boolean] :default Configure the interface description
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
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
      # set_shutdown configures the adminstrative state of the specified
      # interface in the node.  If the value is true, then the interface
      # is adminstratively disabled.  If the value is false, then the
      # interface is adminstratively enabled.  If no value is provided, then
      # the interface is configured with the no keyword which is equivalent
      # to false.  If the default keyword is set to true, then the interface
      # shutdown value is configured using the default keyword.  The default
      # keyword takes precedence over the value keyword if both are provided.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name<
      #     shutdown
      #     no shutdown
      #     default shutdown
      #
      # @param [String] :name The interface name to apply the configuration
      #   to.  The name value must be the full interface identifier
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :value True if the interface should be
      #   administratively disabled or false if the interface should be
      #   administratively enabled
      #
      # @option :opts [Boolean] :default Configure the interface shutdown
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
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

      DEFAULT_ETH_FLOWC_TX = 'off'
      DEFAULT_ETH_FLOWC_RX = 'off'

      ##
      # get returns the specified Etherent interface resource hash that
      # respresents the interface's current configuration in th e node.
      #
      # @example
      #   {
      #     name: <string>
      #     type: 'ethernet'
      #     description: <string>
      #     shutdown: [true, false]
      #     sflow: [true, false]
      #     flowcontrol_send: [on, off]
      #     flowcontrol_receive: [on, off]
      #   }
      #
      # @param [String] :name The interface name to return a resource hash
      #   for from the node's running configuration
      #
      # @return [nil, Hash<Symbol, Object>] Returns the interface resource as
      #   a hash.  If the specified interface name is not found in the node's
      #   configuration a nil object is returned
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response[:type] = 'ethernet'

        response.merge!(parse_sflow(config))
        response.merge!(parse_flowcontrol_send(config))
        response.merge!(parse_flowcontrol_receive(config))

        response
      end

      ##
      # parse_sflow scans the provided configuration block and parse the
      # sflow value.  The sflow values true if sflow is enabled on the
      # interface or returns false if it is not enabled.  The hash returned
      # is intended to be merged into the interface hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_sflow(config)
        value = /no  enable/ =~ config
        { sflow: value.nil? }
      end
      private :parse_sflow

      ##
      # parse_flowcontrol_send scans the provided configuration block and
      # parses the flowcontrol send value.  If the interface flowcontrol value
      # is not configured, then this method will return the value of
      # DEFAULT_ETH_FLOWC_TX.  The hash returned is intended to be merged into
      # the interface resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_flowcontrol_send(config)
        mdata = /flowcontrol send (\w+)$/.match(config)
        { flowcontrol_send: mdata.nil? ? DEFAULT_ETH_FLOWC_TX : mdata[1] }
      end
      private :parse_flowcontrol_send

      ##
      # parse_flowcontrol_receive scans the provided configuration block and
      # parse the flowcontrol receive value.  If the interface flowcontrol
      # value is not configured, then this method will return the value of
      # DEFAULT_ETH_FLOWC_RX.  The hash returned is intended to be merged into
      # the interface resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_flowcontrol_receive(config)
        mdata = /flowcontrol receive (\w+)$/.match(config)
        { flowcontrol_receive: mdata.nil? ? DEFAULT_ETH_FLOWC_RX : mdata[1] }
      end
      private :parse_flowcontrol_receive

      ##
      # create overrides the create method from the BaseInterface and raises
      # an exception because Ethernet interface creation is not supported.
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
      # delete overrides the delete method fro the BaseInterface instance and
      # raises an exception because Ethernet interface deletion is not
      # supported.
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
      # set_sflow configures the administrative state of sflow on the
      # interface.  Setting the value to true enables sflow on the interface
      # and setting the value to false disables sflow on the interface.  If the
      # value is not provided, the sflow state is negated using the no keyword.
      # If the default keyword is set to true, then the sflow value is
      # defaulted using the default keyword.  The default keyword takes
      # precedence over the value keyword
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     sflow enable
      #     no sflow enable
      #     default sflow
      #
      # @param [String] :name The interface name to apply the configuration
      #   values to.  The name must be the full interface identifier.
      #
      # @param [Hash] :opts optional keyword arguments
      #
      # @option :opts [Boolean] :value Enables  sflow if the value is true or
      #   disables sflow on the interface if false
      #
      # @option :opts [Boolean] :default Configures the sflow value on the
      #   interface using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
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
      # set_flowcontrol configures the flowcontrol value either on or off for
      # the for the specified interface in the specified direction (either send
      # or receive).  If the value is not provided then the configuration is
      # negated using the no keyword.  If the default keyword is set to true,
      # then the state value is defaulted using the default keyword.  The
      # default keyword takes precedence over the value keyword
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #   flowcontrol [send | receive] [on, off]
      #   no flowcontrol [send | receive]
      #   default flowcontrol [send | receive]
      #
      # @param [String] :name The interface name to apply the configuration
      #   values to.  The name must be the full interface identifier.
      #
      # @param [String] :direction Specifies the flowcontrol direction to
      #   configure.  Valid values include send and receive.
      #
      # @param [Hash] :opts optional keyword arguments
      #
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting for.  Valid values include on or off
      #
      # @option :opts [Boolean] :default Configures the flowcontrol value on
      #   the interface using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
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
      # set_flowcontrol_send is a convenience function for configuring the
      # value of interface flowcontrol.
      #
      # @see set_flowcontrol
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #   flowcontrol [send | receive] [on, off]
      #   no flowcontrol [send | receive]
      #   default flowcontrol [send | receive]
      #
      # @param [String] :name The interface name to apply the configuration
      #   values to.  The name must be the full interface identifier.
      #
      # @param [Hash] :opts optional keyword arguments
      #
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting for.  Valid values include on or off
      #
      # @option :opts [Boolean] :default Configures the flowcontrol value on
      #   the interface using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_flowcontrol_send(name, opts = {})
        set_flowcontrol(name, 'send', opts)
      end

      ##
      # set_flowcontrol_receive is a convenience function for configuring th e
      # value of interface flowcontrol
      #
      # @see set_flowcontrol
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #   flowcontrol [send | receive] [on, off]
      #   no flowcontrol [send | receive]
      #   default flowcontrol [send | receive]
      #
      # @param [String] :name The interface name to apply the configuration
      #   values to.  The name must be the full interface identifier.
      #
      # @param [Hash] :opts optional keyword arguments
      #
      # @option :opts [String] :value Specifies the value to configure the
      #   flowcontrol setting for.  Valid values include on or off
      #
      # @option :opts [Boolean] :default Configures the flowcontrol value on
      #   the interface using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_flowcontrol_receive(name, opts = {})
        set_flowcontrol(name, 'receive', opts)
      end
    end

    class PortchannelInterface < BaseInterface

      DEFAULT_LACP_FALLBACK = 'disabled'
      DEFAULT_MIN_LINKS = '0'

      ##
      #
      # @example
      #   {
      #     type: 'portchannel'
      #     description: <string>
      #     shutdown: [true, false]
      #     members: array[<strings>]
      #     lacp_mode: [active, passive, on]
      #     minimum_links: <string>
      #     lacp_timeout: <string>
      #     lacp_fallback: [static, individual, disabled]
      #   }
      #
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response[:type] = 'portchannel'
        response.merge!(parse_members(name))
        response.merge!(parse_lacp_mode(name))
        response.merge!(parse_minimum_links(config))
        response.merge!(parse_lacp_fallback(config))
        response.merge!(parse_lacp_timeout(config))
        response
      end

      def parse_members(name)
        grpid = name.scan(/(?<=Port-Channel)\d+/)[0]
        command = "show port-channel #{grpid} all-ports"
        config = node.enable(command, format: 'text')
        values = config.first[:result]['output'].scan(/Ethernet[\d\/]*/)
        { members: values }
      end

      def parse_lacp_mode(name)
        members = parse_members(name)[:members]
        return { lacp_mode: 'on' } unless members
        config = get_block("interface #{members.first}")
        mdata = /channel-group \d+ mode (\w+)/.match(config)
        { lacp_mode: mdata.nil? ? 'on' : mdata[1] }
      end

      def parse_minimum_links(config)
        mdata = /port-channel min-links (\d+)$/.match(config)
        { minimum_links: mdata.nil? ? DEFAULT_MIN_LINKS : mdata[1] }
      end

      def parse_lacp_fallback(config)
        mdata = /lacp fallback (static|individual)/.match(config)
        { lacp_fallback: mdata.nil? ? DEFAULT_LACP_FALLBACK : mdata[1] }
      end

      def parse_lacp_timeout(config)
        mdata = /lacp fallback timeout (\d+)$/.match(config)
        { lacp_timeout: mdata[1] }
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
        current_members = Set.new parse_members(name)[:members]
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
        lacp = parse_lacp_mode(name)[:lacp_mode]
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

        parse_members(name)[:members].each do |member|
          remove_commands << "interface #{member}"
          remove_commands << "no channel-group #{grpid}"
          add_commands << "interface #{member}"
          add_commands << "channel-group #{grpid} mode #{mode}"
        end
        configure remove_commands + add_commands
      end

      def set_lacp_fallback(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default port-channel lacp fallback'
        when false
          if [nil, 'disabled'].include?(value)
            cmds << 'no port-channel lacp fallback'
          else
            cmds << "port-channel lacp fallback #{value}"
          end
        end
        configure(cmds)
      end

      def set_lacp_timeout(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default port-channel lacp fallback timeout'
        when false
          cmds << (value ? "port-channel lacp fallback timeout #{value}" : \
                           'no port-channel lacp fallback timeout')
        end
        configure(cmds)
      end
    end

    class VxlanInterface < BaseInterface

      DEFAULT_SRC_INTF = ''
      DEFAULT_MCAST_GRP = ''

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
        config = get_block("interface #{name}")
        return nil unless config

        response = super(name)
        response[:type] = 'vxlan'
        response.merge!(parse_source_interface(config))
        response.merge!(parse_multicast_group(config))
        response
      end

      def parse_source_interface(config)
        mdata = /source-interface ([^\s]+)$/.match(config)
        { source_interface: mdata.nil? ? DEFAULT_SRC_INTF : mdata[1] }
      end

      def parse_multicast_group(config)
        mdata = /multicast-group ([^\s]+)$/.match(config)
        { multicast_group: mdata.nil? ? DEFAULT_MCAST_GRP : mdata[1] }
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
