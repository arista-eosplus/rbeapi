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
    #
    # The Ipinterface class provides an instance for managing logical
    # IP interfaces configured using eAPI.
    class Ipinterfaces < Entity
      DEFAULT_ADDRESS = ''
      DEFAULT_LOAD_INTERVAL = ''

      ##
      # get returns a resource hash that represents the configuration of the IP
      # interface from the nodes running configuration.
      #
      # @example
      #   {
      #     address: <string>,
      #     mtu: <string>,
      #     helper_addresses: array<strings>
      #     load_interval: <string>
      #   }
      #
      # @param name [String] The full interface identifier of the interface to
      #   return the resource configuration hash for. The name must be the
      #   full name (Ethernet, not Et).
      #
      # @return [nil, Hash<Symbol, Object>] Returns the ip interface
      #   configuration as a hash. If the provided interface name is not a
      #   configured ip address, nil is returned.
      def get(name)
        config = get_block("interface #{name}")
        return nil unless config
        return nil if /\s{3}switchport$/ =~ config

        response = {}
        response.merge!(parse_address(config))
        response.merge!(parse_mtu(config))
        response.merge!(parse_helper_addresses(config))
        response.merge!(parse_load_interval(config))
        response
      end

      ##
      # getall returns a hash object that represents all ip interfaces
      # configured on the node from the current running configuration.
      #
      # @example
      #   {
      #     <name>: {
      #       address: <string>,
      #       mtu: <string>,
      #       helper_addresses: array<strings>
      #       load_interval: <string>
      #     },
      #     <name>: {
      #       address: <string>,
      #       mtu: <string>,
      #       helper_addresses: array<strings>
      #       load_interval: <string>
      #     },
      #     ...
      #   }
      #
      # @see get Ipaddress resource example
      #
      # @return [Hash<Symbol, Object>] Returns a hash object that
      #   represents all of the configured IP addresses found. If no IP
      #   addresses are configured, then an empty hash is returned.
      def getall
        interfaces = config.scan(/(?<=^interface\s).+/)
        interfaces.each_with_object({}) do |name, hsh|
          values = get name
          hsh[name] = values if values
        end
      end

      ##
      # parse_address scans the provided configuration block and extracts
      # the interface address, if configured, and returns it. If there is
      # no IP address configured, then this method will return the
      # DEFAULT_ADDRESS. The return value is intended to be merged into the
      # ipaddress resource hash.
      #
      # @api private
      #
      # @param config [String] The IP interface configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_address(config)
        mdata = /(?<=^\s{3}ip\saddress\s)(.+)$/.match(config)
        { address: mdata.nil? ? DEFAULT_ADDRESS : mdata[1] }
      end
      private :parse_address

      ##
      # parse_mtu scans the provided configuration block and extracts the IP
      # interface MTU value. The MTU value is expected to always be present in
      # the configuration blcok. The return value is intended to be merged
      # into the ipaddress resource hash.
      #
      # @api private
      #
      # @param config [String] The IP interface configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_mtu(config)
        mdata = /(?<=mtu\s)(\d+)$/.match(config)
        { mtu: mdata.nil? ? '' : mdata[1] }
      end
      private :parse_mtu

      ##
      # parse_helper_addresses scans the provided configuration block and
      # extracts any configured IP helper address values. The interface could
      # be configured with one or more helper addresses. If no helper
      # addresses are configured, then an empty array is set in the return
      # hash. The return value is intended to be merged into the ipaddress
      # resource hash.
      #
      # @api private
      #
      # @param config [String] The IP interface configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_helper_addresses(config)
        helpers = config.scan(/(?<=\s{3}ip\shelper-address\s).+$/)
        { helper_addresses: helpers }
      end
      private :parse_helper_addresses

      ##
      # parse_load_interval scans the provided configuration block and
      # parse the load-interval value. If the interface load-interval
      # value is not configured, then this method will return the value of
      # DEFAULT_LOAD_INTERVAL. The hash returned is intended to be merged into
      # the interface resource hash.
      #
      # @api private
      #
      # @param config [String] The configuration block to parse.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_load_interval(config)
        mdata = /load-interval (\w+)$/.match(config)
        { load_interval: mdata.nil? ? DEFAULT_LOAD_INTERVAL : mdata[1] }
      end
      private :parse_load_interval

      ##
      # create will create a new IP interface on the node. If the ip interface
      # already exists in the configuration, this method will still return
      # successful. This method will cause an existing layer 2 interface
      # (switchport) to be deleted if it exists in the node's configuration.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   interface <name>
      #     no switchport
      #
      # @param name [String] The full interface name of the port to create the
      #   logical interface on. The name must be the full interface
      #   identifier.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def create(name)
        configure(["interface #{name}", 'no switchport'])
      end

      ##
      # delete will delete an existing IP interface in the node's current
      # configuration. If the IP interface does not exist on the specified
      # interface, this method will still return success. This command will
      # default the interface back to being a switchport.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   interface <name>
      #     no ip address
      #     switchport
      #
      # @param name [String] The full interface name of the port to delete the
      #   logical interface from. The name must be the full interface name
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def delete(name)
        configure(["interface #{name}", 'no ip address', 'switchport'])
      end

      ##
      # set_address configures a logical IP interface with an address.
      # The address value must be in the form of A.B.C.D/E. If the enable
      # keyword is false, then the interface address is negated using the
      # config no keyword. If the default option is set to true, then the
      # ip address # value is defaulted using the default keyword. The
      # default keyword has precedence over the enable keyword if both
      # options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   interface <name>
      #     ip address <value>
      #     no ip address
      #     default ip address
      #
      # @param name [String] The name of the interface to configure the
      #   address in the node. The name must be the full interface name.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] The value to configure the address to
      #   for the specified interface name. The value must be in the form
      #   of A.B.C.D/E.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ip address value using
      #   the default keyword.
      #
      # @return [Boolean] Returns True if the command completed successfully.
      def set_address(name, opts = {})
        cmds = command_builder('ip address', opts)
        configure_interface(name, cmds)
      end

      ##
      # set_mtu configures the IP mtu value of the ip interface in the nodes
      # configuration. If the enable option is false, then the ip mtu value is
      # configured using the no keyword. If the default keyword option is
      # provided and set to true then the ip mtu value is configured using the
      # default keyword. The default keyword has precedence over the enable
      # keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   interface <name>
      #     mtu <value>
      #     no mtu
      #     default mtu
      #
      # @param name [String] The name of the interface to configure the
      #   address in the node. The name must be the full interface name.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] The value to configure the IP MTU to in
      #   the nodes configuration. Valid values are in the range of 68 to 9214
      #   bytes. The default is 1500 bytes.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the ip mtu value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_mtu(name, opts = {})
        cmds = command_builder('mtu', opts)
        configure_interface(name, cmds)
      end

      ##
      # set_helper_addresses configures the list of helper addresses on the ip
      # interface. An IP interface can have one or more helper addresses
      # configured. If no value is provided, the helper address configuration
      # is set using the no keyword. If the default option is specified and
      # set to true, then the helper address values are defaulted using the
      # default keyword.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   interface <name>
      #     ip helper-address <value>
      #     no ip helper-address
      #     default ip helper-address
      #
      # @param name [String] The name of the interface to configure the
      #   address in the node. The name must be the full interface name.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [Array] The list of IP addresses to configure as
      #   helper address on the interface. The helper addresses must be valid
      #   addresses in the main interface's subnet.
      #
      # @option opts default [Boolean] Configure the ip helper address values
      #    using the default keyword.
      #
      def set_helper_addresses(name, opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        if value
          fail ArgumentError, 'value must be an Array' unless value.is_a?(Array)
        end

        case default
        when true
          cmds = 'default ip helper-address'
        when false
          cmds = ['no ip helper-address']
          value.each { |addr| cmds << "ip helper-address #{addr}" } if enable
        end
        configure_interface(name, cmds)
      end

      ##
      # set_load_interval is a convenience function for configuring the
      # value of interface load-interval
      #
      # @param name [String] The interface name to apply the configuration
      # values to. The name must be the full interface identifier.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] Specifies the value to configure the
      # load-interval setting for. Valid values are between 5 and 600.
      #
      # @option opts default [Boolean] Configures the load-interval value on
      # the interface using the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_load_interval(name, opts = {})
        cmds = command_builder("load-interval", opts)
        configure_interface(name, cmds)
      end
    end
  end
end
