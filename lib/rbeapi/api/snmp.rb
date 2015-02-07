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
    # The Snmp class provides an instance for working with the global
    # SNMP configuration of the node
    #
    class Snmp < Entity

      ##
      # Returns the SNMP resource
      #
      # Example
      #   {
      #     "location": <string>,
      #     "contact": <string>,
      #     "chassis_id": <string>,
      #     "source_interface": <string>
      #   }
      #
      # @return [Hash]  A Ruby hash objec that provides the SNMP settings as
      #   key / value pairs.
      def get()

        response = {}

        mdata = /(?<=^snmp-server\slocation\s)(.+)$/.match(config)
        response['location'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=^snmp-server\scontact\s)(.+)$/.match(config)
        response['contact'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=^snmp-server\schassis-id\s)(.+)$/.match(config)
        response['chassis_id'] = mdata.nil? ? '' : mdata[0]

        mdata = /(?<=^snmp-server\ssource-interface\s)(.+)$/.match(config)
        response['source_interface'] = mdata.nil? ? '' : mdata[0]

        response
      end

      ##
      # Configure the SNMP location value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the location to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the SNMP contact value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the contact to
      # @option opts [Boolean] :default The value should be set to default
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
      # Configure the SNMP chassis-id value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the chassis-id to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_chassis_id(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = ['default snmp-server chassis-id']
        when false
          cmds = (value.nil? ? "no snmp-server chassis-id" : \
                               "snmp-server chassis-id #{value}")
        end
        configure(cmds)
      end

      ##
      # Configure the SNMP source-interface value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the source-interface to
      # @option opts [Boolean] :default The value should be set to default
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
