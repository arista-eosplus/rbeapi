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

    class Logging < Entity

      ##
      # Returns the current logging configuration from the node's config
      #
      # Example
      #   {
      #     "enable": [true, false],
      #     "hosts": array<string>
      #   }
      #
      # @return [Hash]  A Ruby hash objec that provides the SNMP settings as
      #   key / value pairs.
      def get
        response = {}
        val = /^logging\son$/ =~ config
        response['enable'] = !val.nil?
        response['hosts'] = config.scan(/(?<=^logging\shost\s)[^\s]+/)
        response
      end

      ##
      # Configures the global logging instance as enabled or disabled
      #
      # @param [Hash] :opts Arbitrary keyword arguments
      # @option :opts [Boolean] :value Enables logging globally if value is
      #   configured as true or Disables logging globally if the value is
      #   configured as false
      # @option :opts [Boolean] :default Configures the global logging value
      #   as default.  This keyword argument overrides value
      #
      # @return [Boolean] True if the commands succeeds otherwise False
      def set_enable(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmd = 'default logging on'
        when false
          cmd = value ? 'logging on' : 'no logging on'
        end
        configure cmd
      end

      ##
      # Adds a new logging host to the node's configuration
      #
      # @param [String] :node The IP address or host name of the logging
      #   destination to be added to the configuration
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def add_host(name)
        configure "logging host #{name}"
      end

      ##
      # Removes a logging host from the node's configuration
      #
      # @param [String] :node The IP address or host name of the logging
      #   destination to be removed from  the configuration
      #
      # @return [Boolean] True if the commands succeed otherwise False
      def remove_host(name)
        configure "no logging host #{name}"
      end
    end
  end
end
