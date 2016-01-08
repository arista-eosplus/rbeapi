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
  # Api is module namespace for working with the EOS command API
  module Api
    ##
    # The Logging class manages logging settings on an EOS node.
    class Logging < Entity
      ##
      # get returns the current logging configuration hash extracted from the
      # nodes running configuration.
      #
      # @example
      #   {
      #     enable: [true, false]
      #     hosts: array<strings>
      #   }
      #
      # @return [Hash<Symbol, Object>] returns the logging resource as a hash
      #   object from the nodes current configuration
      def get
        response = {}
        response.merge!(parse_enable)
        response.merge!(parse_hosts)
        response
      end

      ##
      # parse_enable scans the nodes current running configuration and extracts
      # the current enabled state of the logging facility.  The logging enable
      # command is expected to always be in the node's configuration.  This
      # methods return value is intended to be merged into the logging resource
      # hash.
      def parse_enable
        value = /no logging on/ !~ config
        { enable: value }
      end

      ##
      # parse_hosts scans the nodes current running configuration and extracts
      # the configured logging host destinations if any are configured.  If no
      # logging hosts are configured, then the value for hosts will be an empty
      # array.  The return value is intended to be merged into the logging
      # resource hash
      def parse_hosts
        hosts = config.scan(/(?<=^logging\shost\s)[^\s]+/)
        { hosts: hosts }
      end
      private :parse_hosts

      ##
      # set_enable configures the global logging instance on the node as either
      # enabled or disabled.  If the enable keyword is set to true then logging
      # is globally enabled and if set to false, it is globally disabled.  If
      # the default keyword is specified and set to true, then the configuration
      # is defaulted using the default keyword.  The default keyword option
      # takes precedence over the enable keyword if both options are specified.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   logging on
      #   no logging on
      #   default logging on
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :enable Enables logging globally if value is
      #   true or disabled logging globally if value is false
      #
      # @option :opts [Boolean] :default Configure the ip address value using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_enable(opts = {})
        cmd = command_builder('logging on', opts)
        configure cmd
      end

      ##
      # add_host configures a new logging destination host address or hostname
      # to the list of logging destinations.  If the host is already configured
      # in the list of destinations, this method will return successfully.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   logging host <name>
      #
      # @param [String] :name The host name or ip address of the destination
      #   node to send logging information to.
      #
      # @return [Boolean] returns true if the command completed successfully
      def add_host(name)
        configure "logging host #{name}"
      end

      ##
      # remove_host deletes a logging destination host name or address form the
      # list of logging destinations.   If the host is not in the list of
      # configured hosts, this method will still return successfully.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   no logging host <name>
      #
      # @param [String] :name The host name or ip address of the destination
      #   host to remove from the nodes current configuration
      #
      # @return [Boolean] returns true if the commands completed successfully
      def remove_host(name)
        configure "no logging host #{name}"
      end
    end
  end
end
