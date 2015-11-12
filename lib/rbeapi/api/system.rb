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
  # Rbeapi::Api
  module Api
    ##
    # The System class configures the node system services such as
    # hostname and domain name
    class System < Entity
      ##
      # Returns the system settings
      #
      # @example
      #   {
      #     hostname: <string>
      #   }
      #
      # @return [Hash]  A Ruby hash object that provides the system settings as
      #   key/value pairs.
      def get
        response = {}
        response.merge!(parse_hostname(config))
        response.merge!(parse_iprouting(config))
        response
      end

      def parse_hostname(config)
        mdata = /(?<=^hostname\s)(.+)$/.match(config)
        { hostname: mdata.nil? ? '' : mdata[1] }
      end

      def parse_iprouting(config)
        mdata = /no\sip\srouting/.match(config)
        { iprouting: mdata.nil? ? true : false }
      end

      ##
      # Configures the system hostname value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the hostname to
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_hostname(opts = {})
        cmd = command_builder('hostname', opts)
        configure(cmd)
      end

      ##
      # Configures the state of global ip routing
      #
      # @param [Hash] opts The configuration parameters
      # @option :opts [Boolean] :enable True if ip routing should be enabled
      #  or False if ip routing should be disabled. Default is true.
      # @option opts [Boolean] :default Controls the use of the default
      #  keyword. Default is false.
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_iprouting(opts = {})
        cmd = command_builder('ip routing', opts)
        configure(cmd)
      end
    end
  end
end
