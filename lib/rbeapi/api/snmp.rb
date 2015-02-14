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

  ##
  # Api is module namespace for working with eAPI abstractions
  module Api

    ##
    # The Snmp class provides a class implementation for working with the
    # nodes SNMP conifguration entity.  This class presents an abstraction
    # of the node's snmp configuration from the running config.
    #
    # @eos_version 4.13.7M
    class Snmp < Entity

      DEFAULT_SNMP_LOCATION = ''
      DEFAULT_SNMP_CONTACT = ''
      DEFAULT_SNMP_CHASSIS_ID = ''
      DEFAULT_SNMP_SOURCE_INTERFACE = ''

      ##
      # get returns the snmp resource Hash that represents the nodes snmp
      # configuration abstraction from the running config.
      #
      # @example
      #   {
      #     location: <string>
      #     contact: <string>
      #     chassis_id: <string>
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
      # set_location updates the snmp location value in the nodes running
      # configuration.  If the value is not provided in the opts Hash then
      # the snmp location value is negated using the no keyword.  If the
      # default keyword is set to true, then the snmp location value is
      # defaulted using the default keyword.  The default parameter takes
      # precedence over the value keyword.
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
      # @option opts [Boolean] :default Configure the snmp location value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_location(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = ['default snmp-server location']
        when false
          cmds = (value.nil? ? "no snmp-server location" : \
                               "snmp-server location #{value}")
        end
        configure(cmds)
      end

      ##
      # set_contact updates the snmp contact value in the nodes running
      # configuration.  If the value is not provided in the opts Hash then
      # the snmp contact value is negated using the no keyword.  If the
      # default keyword is set to true, then the snmp contact value is
      # defaulted using the default keyword.  The default parameter takes
      # precedence over the value keyword.
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
      # @option opts [Boolean] :default Configures the snmp contact value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_contact(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = ['default snmp-server contact']
        when false
          cmds = (value.nil? ? "no snmp-server contact" : \
                               "snmp-server contact #{value}")
        end
        configure(cmds)
      end

      ##
      # set_chassis_id updates the snmp chassis id value in the nodes
      # running configuration.  If the value is not provided in the opts
      # Hash then the snmp chassis id value is negated using the no
      # keyword.  If the default keyword is set to true, then the snmp
      # chassis id value is defaulted using the default keyword.  The default
      # keyword takes precedence over the value keyword.
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
      # @option opts [Boolean] :default Configures the snmp chassis id value
      #   using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_chassis_id(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = 'default snmp-server chassis-id'
        when false
          cmds = (value.nil? ? "no snmp-server chassis-id" : \
                               "snmp-server chassis-id #{value}")
        end
        configure(cmds)
      end

      ##
      # set_source_interface updates the snmp source interface value in the
      # nodes running configuration.  If the value is not provided in the opts
      # Hash then the snmp source interface is negated using the no keyword.
      # If the deafult keyword is set to true, then the snmp source interface
      # value is defaulted using the default keyword.  The deafult keyword
      # takes precedence over the value keyword.
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
      # @option opts [Boolean] :default Configures the snmp source interface
      #   value using the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_source_interface(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = ['default snmp-server source-interface']
        when false
          cmds = (value.nil? ? "no snmp-server source-interface" : \
                               "snmp-server source-interface #{value}")
        end
       configure(cmds)
      end
    end
  end
end
