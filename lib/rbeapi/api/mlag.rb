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

    ##
    # The Mlag class provides a configuration instance for working with
    # the global MLAG configuration of the node
    class Mlag < Entity

      DEFAULT_DOMAIN_ID = ''
      DEFAULT_LOCAL_INTF = ''
      DEFAULT_PEER_ADDR = ''
      DEFAULT_PEER_LINK = ''

      ##
      # get returns the mlag configuration from the node as a resource hash
      #
      # @example
      #   {
      #     domain_id: <string>
      #     local_interface: <string>
      #     peer_address: <string>
      #     peer_link: <string>
      #     shutdown: [true, false]
      #     interfaces: {...}
      #   }
      #
      # @see MlagInterfaces interface resource message
      #
      # @return [nil, Hash<Symbol, Object] returns the nodes current running
      #   configuration as a Hash.  If mlag is not configured on the node this
      #   method will return nil
      def get()
        config = get_block('mlag configuration')
        response = {}
        response.merge!(parse_domain_id(config))
        response.merge!(parse_local_interface(config))
        response.merge!(parse_peer_address(config))
        response.merge!(parse_peer_link(config))
        response.merge!(parse_shutdown(config))
        response[:interfaces] = interfaces.getall
        response
      end

      ##
      # parse_domain_id scans the current nodes running configuration and
      # extracts the mlag domain-id value.  If the mlag domain-id has not been
      # configured, then this method will return DEFAULT_DOMAIN_ID.  The return
      # value is intended to be merged into the resource hash
      #
      # @api private
      #
      # @param [String] :config The mlag configuration block retrieved from the
      #   nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_domain_id(config)
        mdata = /(?<=\s{3}domain-id\s)(.+)$/.match(config)
        { domain_id: mdata.nil? ? DEFAULT_DOMAIN_ID : mdata[1] }
      end
      private :parse_domain_id

      ##
      # parse_local_interface scans the current nodes running configuration and
      # extracts the mlag local-interface value.  If the mlag local-interface
      # has not been configured, this method will return DEFAULT_LOCAL_INTF.
      # The return value is intended to be merged into the resource hash
      #
      # @api private
      #
      # @param [String] :config The mlag configuration block retrieved from the
      #   nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_local_interface(config)
        mdata = /(?<=\s{3}local-interface\s)(.+)$/.match(config)
        { local_interface: mdata.nil? ? DEFAULT_LOCAL_INTF : mdata[1] }
      end
      private :parse_local_interface

      ##
      # parse_peer_address scans the current nodes running configuration and
      # extracts the mlag peer-address value.  If the mlag peer-address has not
      # been configured, this method will return DEFAULT_PEER_ADDR.  The return
      # value is intended to be merged into the resource hash.
      #
      # @api private
      #
      # @param [String] :config The mlag configuration block retrieved from the
      #   nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_peer_address(config)
        mdata = /(?<=\s{3}peer-address\s)(.+)$/.match(config)
        { peer_address: mdata.nil? ? DEFAULT_PEER_ADDR : mdata[1] }
      end
      private :parse_peer_address

      ##
      # parse_peer_link scans the current nodes running configuration and
      # extracts the mlag peer-link value.  If the mlag peer-link hash not been
      # configure, this method will return DEFAULT_PEER_LINK.  The return value
      # is intended to be merged into the resource hash.
      #
      # @api private
      #
      # @param [String] :config The mlag configuration block retrieved from the
      #   nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_peer_link(config)
        mdata = /(?<=\s{3}peer-link\s)(.+)$/.match(config)
        { peer_link: mdata.nil? ? DEFAULT_PEER_LINK : mdata[1] }
      end
      private :parse_peer_link

      ##
      # parse_shutdown scans the current nodes mlag configuration and extracts
      # the mlag shutdown value.  The mlag configuration should always return
      # the value of shutdown from the configuration block.  Ths return value
      # is intended to be merged into the resource hash.
      #
      # @api private
      #
      # @param [String] :config The mlag configuration block retrieved from the
      #   nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_shutdown(config)
        value = /\s{3}no shutdown/ !~ config
        { shutdown: value }
      end
      private :parse_shutdown

      ##
      # interfaces returns a memoized instance of MlagInterfaces that provide
      # an api for working with mlag interfaces in the nodes current
      # configuration.
      #
      # @see MlagInterfaces
      #
      # @return [Object] returns an instance of MlagInterfaces
      def interfaces
        return @interfaces if @interfaces
        @interfaces = MlagInterfaces.new(node)
        @interfaces
      end

      ##
      # set_domain_id configures the mlag domain-id value in the current nodes
      # running configuration. If the value keyword is not provided, the
      # domain-id is configured with the no keyword.  If the default keyword is
      # provided, the configuration is defaulted using the default keyword.
      # The default keyword takes precedence over the value keywork if both
      # options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   mlag configuration
      #     domain-id <value>
      #     no domain-id
      #     default domain-id
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configurue the mlag
      #   domain-id to.
      #
      # @option :opts [Boolean] :default Configure the domain-id value using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_domain_id(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['mlag configuration']
        case default
        when true
          cmds << 'default domain-id'
        when false
          cmds << (value ? "domain-id #{value}" : 'no domain-id')
        end
        configure(cmds)
      end

      ##
      # set_local_interface configures the mlag local-interface value in the
      # current nodes running configuration. If the value keyword is not
      # provided, the local-interface is configured with the no keyword.  If
      # the default keyword is provided, the configuration is defaulted using
      # the default keyword.  The default keyword takes precedence over the
      # value keywork if both options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   mlag configuration
      #     local-interface <value>
      #     no local-interface
      #     default local-interface
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configurue the mlag
      #   local-interface to.  The local-interface accepts full interface
      #   identifiers and expects a Vlan interface
      #
      # @option :opts [Boolean] :default Configure the local-interface value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_local_interface(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['mlag configuration']
        case default
        when true
          cmds << 'default local-interface'
        when false
          cmds << (value ? "local-interface #{value}" : 'no local-interface')
        end
        configure(cmds)
      end

      ##
      # set_peer_link configures the mlag peer-link value in the current nodes
      # running configuration. If the value keyword is not provided, the
      # peer-link is configured with the no keyword.  If the default keyword
      # is provided, the configuration is defaulted using the default keyword.
      # The default keyword takes precedence over the value keywork if both
      # options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   mlag configuration
      #     peer-link <value>
      #     no peer-link
      #     default peer-link
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configurue the mlag
      #   peer-link to.  The peer-link accepts full interface identifiers
      #   and expects an Ethernet or Port-Channel  interface
      #
      # @option :opts [Boolean] :default Configure the peer-link using the
      #   default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_peer_link(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['mlag configuration']
        case default
        when true
          cmds << 'default peer-link'
        when false
          cmds << (value ? "peer-link #{value}" : 'no peer-link')
        end
        configure(cmds)
      end

      ##
      # set_peer_address configures the mlag peer-address value in the current
      # nodes running configuration. If the value keyword is not provided, the
      # peer-address is configured with the no keyword.  If the default keyword
      # is provided, the configuration is defaulted using the default keyword.
      # The default keyword takes precedence over the value keywork if both
      # options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   mlag configuration
      #     peer-address <value>
      #     no peer-address
      #     default peer-address
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configurue the mlag
      #   peer-address to.  The peer-address accepts an IP address in the form
      #   of A.B.C.D/E
      #
      # @option :opts [Boolean] :default Configure the peer-address using the
      #   default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_peer_address(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['mlag configuration']
        case default
        when true
          cmds << 'default peer-address'
        when false
          cmds << (value ? "peer-address #{value}" : 'no peer-address')
        end
        configure(cmds)
      end

      ##
      # set_shutdown configures the administrative state of the mlag process on
      # the current node.  If the value is true, then mlag is enabled and if
      # the value is false, then mlag is disabled.  If no value is provided,
      # the shutdown command is configured using the no keyword argument. If
      # the default keyword is provided, the configuration is defaulted using
      # the default keyword. The default keyword takes precedence over the
      # value keywork if both options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   mlag configuration
      #     shutdown
      #     no shutdown
      #     default shutdown
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :value Enables the mlag configuration if value
      #   is true or disables the mlag configuration if value is false.
      #
      # @option :opts [Boolean] :default Configure the shutdown value using the
      #   default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_shutdown(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ['mlag configuration']
        case default
        when true
          cmds << 'default shutdown'
        when false
          cmds << (value ? 'shutdown' : 'no shutdown')
        end
        configure(cmds)
      end
    end

    class MlagInterfaces < Entity

      ##
      # get returns the mlag interface configuration as a hash object.  If the
      # specified interface name is not configured as an mlag interface this
      # method will return nil
      #
      # @example
      #   {
      #     mlag_id: <string>
      #   }
      #
      # @param [String] :name The full interface name of the interface to
      #   return the mlag interface hash for.
      #
      # @return [nil, Hash<Symbol, Object>] returns the interface configuration
      #   as a resource hash.  If the interface is not configured as an mlag
      #   interface nil is returned.
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config
        mdata = /(?<=\s{3}mlag\s)(.+)$/.match(config)
        return nil unless mdata
        { mlag_id: mdata[1] }
      end

      ##
      # getall scans the nodes current running configuration and returns a
      # hash of all mlag interfaces keyed by the interface name.  If no
      # interfaces are configured, an empty hash object is returned
      #
      # @see get Interface resource example
      #
      # @return [Hash<String, Hash>] returns the nodes mlag interface
      #   configurations as a hash
      def getall
        names = config.scan(/(?<=^interface\s)Po.+/)
        names.each_with_object({}) do |name, response|
          data = get name
          response[name] = data if data
        end
      end

      ##
      # create adds a new mlag interface to the nodes current running
      # configuration.  If the specified interface already exists, then this
      # method will return successfully with the updated mlag id.
      #
      # @see set_mlag_id
      #
      # @param [String] :name The name of of the interface to create.  The name
      #   must be the full interface name.  The value of name is expected to
      #   be a Port-Channel interface.
      #
      # @param [String, Integer] :id The value of the mlag id to configure for
      #   the specified interface.  Valid mlag ids are in the range of 1 to
      #   2000.
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(name, id)
        set_mlag_id(name, value: id)
      end

      ##
      # delete removes a mlag interface from the nodes current running
      # configuration.  If the specified interface does not exist as a mlag
      # interface this method will return successfully
      #
      # @see set_mlag_id
      #
      # @param [String] :name The name of of the interface to remove.  The name
      #   must be the full interface name.
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(name)
        set_mlag_id(name)
      end

      ##
      # default configures a mlag interface using the default keyword.  If the
      # specified interface does not exist as a mlag interface this method
      # will return successfully
      #
      # @see set_mlag_id
      #
      # @param [String] :name The name of of the interface to create.  The name
      #   must be the full interface name.
      #
      # @return [Boolean] returns true if the command completed successfully
      def default(name)
        set_mlag_id(name, default: true)
      end

      ##
      # set_mlag_id configures the mlag id on the interface in the nodes
      # current running configuration.  If the value is not specified, then the
      # interface mlag id is configured using the no keyword.  If the default
      # keyword is provided and set to true, the interface mlag id is
      # configured using the default keyword.  The default keyword takes
      # precedence over the value keyword if both options are specified
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     mlag <value>
      #     no mlag
      #     default mlag
      #
      # @param [String] :name The full interface identifier of the interface
      #   to confgure th mlag id for.
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String, Integer] :value The value to configure the
      #   interface mlag to.  The mlag id should be in the valid range of 1 to
      #   2000
      #
      # @option :opts [Boolean] :default Configure the mlag value using the
      #   default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_mlag_id(name, opts = {})
        value = opts[:value]
        default = opts[:default] || false

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default mlag'
        when false
          cmds << (value ? "mlag #{value}"  : 'no mlag')
        end
        configure(cmds)
      end
    end
  end
end
