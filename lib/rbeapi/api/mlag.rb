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

      ##
      # Returns the global MLAG configuration from the node
      #
      # Example
      #   {
      #     "domain_id": <string>,
      #     "local_interface": <string>,
      #     "peer_address": <string>,
      #     "peer_link": <string>
      #     "shutdown": [true, false]
      #     "interfaces": {...}
      #   }
      #
      # @return [Hash]  A Ruby hash objec that provides the SNMP settings as
      #   key / value pairs.
      def get()

        config = get_block('mlag configuration')
        response = {}

        mdata = /(?<=\s{3}domain-id\s)(.+)$/.match(config)
        response['domain_id'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=\s{3}local-interface\s)(.+)$/.match(config)
        response['local_interface'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=\s{3}peer-address\s)(.+)$/.match(config)
        response['peer_address'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=\s{3}peer-link\s)(.+)$/.match(config)
        response['peer_link'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=\s{3})(no\sshutdown)$/.match(config)
        response['shutdown'] = mdata.nil?

        response['interfaces'] = interfaces.getall

        response
      end

      def interfaces
        return @interfaces if @interfaces
        @interfaces = MlagInterfaces.new(node)
        @interfaces
      end

      ##
      # Configure the MLAG domain-id value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the domain-id to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the MLAG local-interface value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the local-interface to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the MLAG peer-link value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the peer-link to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the MLAG peer-address value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the peer-address to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the MLAG shutdown value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [Boolean] :value The value to set shutdown to
      # @option opts [Boolean] :default The value should be set to default
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
      # Returns a single MLAG interface configuration
      #
      # Example
      #   {
      #     "name": <string>,
      #     "mlag_id": <string>
      #   }
      #
      # @param [String] :name The interface name to return the configuration
      #   values for.  This must be the full interface identifier.
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface confguration.  A nil object is returned if the
      #   specified interface is not configured
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config
        mdata = /(?<=\s{3}mlag\s)(.+)$/.match(config)
        return nil unless mdata
        { 'mlag_id' => mdata[1] }
      end

      ##
      # Returns the collection of MLAG interfaces as a hash index by the
      # interface name
      #
      # Example
      #   {
      #     <name>: {...},
      #     <name>: {...}
      #   }
      #
      # @return [nil, Hash<String, String>] A Ruby hash that represents the
      #   MLAG interface confguration.  A nil object is returned if no
      #   interfaces are configured.
      def getall
        names = config.scan(/(?<=^interface\s)Po.+/)
        names.each_with_object({}) do |name, response|
          data = get name
          response[name] = data if data
        end
      end

      ##
      # Creates a new MLAG interface with the specified mlag id
      #
      # @param [String] :name The name of the interface to create.  The
      #   name argument must be the full interface name.  Valid interfaces
      #   are restricted to Port-Channel interfaces
      # @param [String] :id The MLAG ID to confgure for the specified
      #   interface name
      #
      # @return [Boolean] True if the commands succeeds otherwise False
      def create(name, id)
        set_mlag_id(name, value: id)
      end

      ##
      # Deletes a MLAG interface
      #
      # @param [String] :name The name of the interface to delete.  The
      #   name argument must be the full interface name.  Valid interfaces
      #   are restricted to Port-Channel interfaces
      #
      # @return [Boolean] True if the commands succeeds otherwise False
      def delete(name)
        set_mlag_id(name)
      end

      ##
      # Default a MLAG interface
      #
      # @param [String] :name The name of the interface to default.  The
      #   name argument must be the full interface name.  Valid interfaces
      #   are restricted to Port-Channel interfaces
      #
      # @return [Boolean] True if the commands succeeds otherwise False
      def default(name)
        set_mlag_id(name, default: true)
      end

      ##
      # Configures the MLAG interface mlag value
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [Boolean] :value The value to set interface mlag to
      # @option opts [Boolean] :default The value should be set to default
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
