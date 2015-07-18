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

##
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::Api
  module Api
    ##
    # The Stp class provides a base class instance for working with
    # the EOS spanning-tree configuration
    #
    class Stp < Entity
      ##
      # get returns the current stp configuration parsed from the nodes
      # current running configuration.
      #
      # @example
      #   {
      #     mode: <string>
      #     instances: {...}
      #     interfaces: {...}
      #   }
      #
      # @see StpInstances instances get example
      # @eee StpInterfaces interfaces get example
      #
      # @return [Hash] returns a Hash of attributes derived from eAPI
      def get
        response = {}
        response.merge!(parse_mode)
        response[:instances] = instances.getall
        response[:interfaces] = interfaces.getall
        response
      end

      ##
      # parse_mode scans the nodes running configuration and extracts the
      # value of the spanning-tree mode.  The spanning tree mode is
      # expected to be always be available in the running config.  The return
      # value is intended to be merged into the stp resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_mode
        mdata = /(?<=spanning-tree\smode\s)(\w+)$/.match(config)
        { mode: mdata[1] }
      end

      ##
      # instances returns a memoized instance of StpInstances for configuring
      # individual stp instances.
      #
      # @return [StpInstances] an instance of StpInstances class
      def instances
        return @instances if @instances
        @instances = StpInstances.new(node)
        @instances
      end

      ##
      # interfaces returns a memoized instance of StpInterfaces for
      # configuring individual stp interfaces
      #
      # @return [StpInterfaces] an instance of StpInterfaces class
      def interfaces
        return @interfaces if @interfaces
        @interfaces = StpInterfaces.new(node)
        @interfaces
      end

      ##
      # set_mode configures the stp mode in the global nodes running
      # configuration.  If the enable option is false, then the stp
      # mode is configured with the no keyword argument.  If the default option
      # is specified then the mode is configured with the default keyword
      # argument.  The default keyword argument takes precedence over the enable
      # option if both are provided
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   spanning-tree mode <value>
      #   no spanning-tree mode
      #   default spanning-tree mode
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configure the stp mode to
      #   in the nodes current running configuration
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the stp mode value using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      #
      def set_mode(opts = {})
        cmd = command_builder('spanning-tree mode', opts)
        configure cmd
      end
    end

    ##
    # The StpInstances class provides a class instance for working with
    # spanning-tree instances in EOS
    #
    class StpInstances < Entity
      DEFAULT_STP_PRIORITY = '32768'

      ##
      # get returns the specified stp instance config parsed from the nodes
      # current running configuration.
      #
      # @example
      #   {
      #     priority: <string>
      #   }
      #
      # @return [nil, Hash<Symbol, Object] returns the stp instance config as
      #    a resource hash.  If the instances is not configured this method
      #    will return a nil object
      def get(inst)
        return nil unless parse_instances.include?(inst.to_s)
        response = {}
        response.merge!(parse_priority(inst))
        response
      end

      ##
      # getall returns all configured stp instances parsed from the nodes
      # running configuration.  The return hash is keyed by the instance
      # identifier value
      #
      # @example
      #   {
      #     <inst>: {...}
      #   }
      #
      # @see get Instance get example
      #
      # @return [Hash<Symbol, Object>] returns all configured stp instances
      #   found in the nodes running configuration
      def getall
        parse_instances.each_with_object({}) do |inst, hsh|
          values = get(inst)
          hsh[inst] = values if values
        end
      end

      ##
      # parse_instances will scan the nodes current configuration and extract
      # the list of configured mst instances.  If no instances are configured
      # then this method will return an empty array
      #
      # @api private
      #
      # @return [Array<String>] returns an Array of configured stp instances
      def parse_instances
        config = get_block('spanning-tree mst configuration')
        config.scan(/(?<=^\s{3}instance\s)\d+/)
      end
      private :parse_instances

      ##
      # parse_priority will scan the nodes current configuration and extract
      # the stp priority value for the given stp instance.  If the stp
      # instance priority is not configured, the priority value will be set
      # using DEFAULT_STP_PRIORITY.  The returned hash is intended to be merged
      # into the resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_priority(inst)
        priority_re = /(?<=^spanning-tree\smst\s#{inst}\spriority\s)(.+$)/x
        mdata = priority_re.match(config)
        { priority: mdata.nil? ? DEFAULT_STP_PRIORITY : mdata[1] }
      end
      private :parse_priority

      ##
      # Deletes a configured MST instance
      #
      # @param [String] inst The MST instance to delete
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def delete(inst)
        configure ['spanning-tree mst configuration', "no instance #{inst}",
                   'exit']
      end

      ##
      # Configures the spanning-tree MST priority
      #
      # @param [String] inst The MST instance to configure
      # @param [Hash] opts The configuration parameters for the priority
      # @option opts [string] :value The value to set the priority to
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_priority(inst, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          cmd = "default spanning-tree mst #{inst} priority"
        when false
          if enable
            cmd = "spanning-tree mst #{inst} priority #{value}"
          else
            cmd = "no spanning-tree mst #{inst} priority"
          end
        end
        configure cmd
      end
    end

    ##
    # The StpInterfaces class provides a class instance for working with
    # spanning-tree interfaces in EOS
    #
    class StpInterfaces < Entity
      ##
      # get returns the configured stp interfaces from the nodes running
      # configuration as a resource hash.  If the specified interface is not
      # configured as a switchport then this method will return nil
      #
      # @example
      #   {
      #     portfast: [true, false]
      #     bpduguard: [true, false]
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] returns the stp interface as a
      #   resource hash
      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil if /no switchport$/ =~ config
        response = {}
        response.merge!(parse_portfast(config))
        response.merge!(parse_portfast_type(config))
        response.merge!(parse_bpduguard(config))
        response
      end

      ##
      # getall returns all of the configured stp interfaces parsed from the
      # nodes current running configuration.  The returned hash is keyed by the
      # interface name
      #
      # @example
      #   {
      #     <interface>: {...}
      #   }
      #
      # @see get Interface example
      #
      # @return [Hash<Symbol, Object>] returns the stp interfaces config as a
      #   resource hash from the nodes running configuration
      def getall
        interfaces = config.scan(/(?<=^interface\s)[Et|Po].+/)
        resp = interfaces.each_with_object({}) do |name, hsh|
          values = get(name)
          hsh[name] = values if values
        end
        resp
      end

      ##
      # parse_portfast scans the supplied interface configuration block and
      # parses the value stp portfast.  The value of portfast is either enabled
      # (true) or disabled (false)
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_portfast(config)
        val = /no spanning-tree portfast/ =~ config
        { portfast: val.nil? }
      end
      private :parse_portfast

      ##
      # parse_portfast_type scans the supplied interface configuration block
      # and parses the value stp portfast type.  The value of portfast type
      # is either not set which implies normal (default), edge, or network.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_portfast_type(config)
        if /spanning-tree portfast network/ =~ config
          value = 'network'
        elsif /no spanning-tree portfast/ =~ config
          value = 'normal'
        else
          value = 'edge'
        end
        { portfast_type: value }
      end
      private :parse_portfast_type

      ##
      # parse_bpduguard scans the supplied interface configuration block and
      # parses the value of stp bpduguard.  The value of bpduguard is either
      # disabled (false) or enabled (true)
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_bpduguard(config)
        val = /spanning-tree bpduguard enable/ =~ config
        { bpduguard: !val.nil? }
      end
      private :parse_bpduguard

      ##
      # Configures the interface portfast value
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for portfast
      # @option opts [Boolean] :value The value to set portfast
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_portfast(name, opts = {})
        cmd = command_builder('spanning-tree portfast', opts)
        configure_interface(name, cmd)
      end

      ##
      # Configures the interface portfast type value
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for portfast type
      # @option opts [String] :value The value to set portfast type to.
      #   The value must be set for calls to this method.
      # @option opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_portfast_type(name, opts = {})
        value = opts[:value]
        fail ArgumentError, 'value must be set' unless value
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          cmds = "default spanning-tree portfast #{value}"
        when false
          if enable
            cmds = "spanning-tree portfast #{value}"
          else
            cmds = "no spanning-tree portfast #{value}"
          end
        end
        configure_interface(name, cmds)
      end

      ##
      # Configures the interface bpdu guard value
      #
      # @param [String] name The name of the interface to configure
      # @param [Hash] opts The configuration parameters for bpduguard
      # @option opts [Boolean] :value The value to set bpduguard
      # @option opts [Boolean] :enable If false then the bpduguard is
      #   disabled. If true then the bpduguard is enabled. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def set_bpduguard(name, opts = {})
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          cmds = 'default spanning-tree bpduguard'
        when false
          if enable
            cmds = 'spanning-tree bpduguard enable'
          else
            cmds = 'spanning-tree bpduguard disable'
          end
        end
        configure_interface(name, cmds)
      end
    end
  end
end
