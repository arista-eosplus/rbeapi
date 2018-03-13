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
    ##
    # The Logging class manages logging settings on an EOS node.
    class Logging < Entity
      SEV_NUM = {
        'emergencies' => 0,
        'alerts' => 1,
        'critical' => 2,
        'errors' => 3,
        'warnings' => 4,
        'notifications' => 5,
        'informational' => 6,
        'debugging' => 7
      }.freeze
      ##
      # get returns the current logging configuration hash extracted from the
      # nodes running configuration.
      #
      # @example
      #   {
      #     enable: [true, false],
      #     hosts: array<strings>
      #   }
      #
      # @return [Hash<Symbol, Object>] Returns the logging resource as a hash
      #   object from the nodes current configuration.
      def get
        response = {}
        response.merge!(parse_enable)
        response.merge!(parse_console_level)
        response.merge!(parse_monitor_level)
        response.merge!(parse_timestamp_units)
        response.merge!(parse_source)
        response.merge!(parse_hosts)
        response
      end

      ##
      # parse_enable scans the nodes current running configuration and extracts
      # the current enabled state of the logging facility. The logging enable
      # command is expected to always be in the node's configuration. This
      # methods return value is intended to be merged into the logging resource
      # hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_enable
        value = /no logging on/ !~ config
        { enable: value }
      end
      private :parse_enable

      ##
      # parse_console_level scans the nodes current running configuration and
      # extracts the current enabled state of the logging facility. The logging
      # enable command is expected to always be in the node's configuration.
      # This methods return value is intended to be merged into the logging
      # resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_console_level
        level = config.scan(/^logging console ([^\s]+)/).first
        { console: SEV_NUM[level[0]] }
      end
      private :parse_console_level

      ##
      # parse_monitor_level scans the nodes current running configuration and
      # extracts the current enabled state of the logging facility. The
      # logging enable command is expected to always be in the node's
      # configuration. This methods return value is intended to be merged into
      # the logging resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_monitor_level
        level = config.scan(/^logging monitor ([^\s]+)/).first
        { monitor: SEV_NUM[level[0]] }
      end
      private :parse_monitor_level

      ##
      # parse_timestamp_units scans the nodes current running configuration
      # and extracts the current configured value of the logging timestamps.
      # The logging timestamps command is expected to always be in the node's
      # configuration. This methods return value is intended to be merged into
      # the logging resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_timestamp_units
        value = config.scan(/^logging format timestamp ([^\s]+)/).first
        units = value[0] == 'traditional' ? 'seconds' : 'milliseconds'
        { time_stamp_units: units }
      end
      private :parse_timestamp_units

      ##
      # parse_source scans the nodes' current running configuration and extracts
      # the configured logging source interfaces if any are configured. If no
      # logging sources are configured, then the value will be an empty
      # array. The return value requires conversion from a hash to a pair of
      # ordered arrays to be merged into the logging resource hash.
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_source
        entries = config.scan(
          /^logging(?:\svrf\s([^\s]+))?\ssource-interface\s([^\s]+)/
        )
        sources = {}
        entries.each do |vrf, intf|
          vrf = vrf.nil? ? 'default' : vrf
          sources[vrf.to_s] = intf
        end
        { source: sources }
      end
      private :parse_source

      ##
      # parse_hosts scans the nodes current running configuration and extracts
      # the configured logging host destinations if any are configured. If no
      # logging hosts are configured, then the value for hosts will be an empty
      # array. The return value is intended to be merged into the logging
      # resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_hosts
        entries = config.scan(
          /^logging(?:\svrf\s([^\s]+))?\shost\s([^\s]+)\s(\d+)
          \sprotocol\s([^\s]+)/x
        )
        hosts = []
        entries.each do |vrf, address, port, proto|
          hosts << { address: address,
                     vrf: vrf.nil? ? 'default' : vrf,
                     port: port,
                     protocol: proto }
        end
        { hosts: hosts }
      end
      private :parse_hosts

      ##
      # set_enable configures the global logging instance on the node as either
      # enabled or disabled. If the enable keyword is set to true then logging
      # is globally enabled and if set to false, it is globally disabled. If
      # the default keyword is specified and set to true, then the configuration
      # is defaulted using the default keyword. The default keyword option
      # takes precedence over the enable keyword if both options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   logging on
      #   no logging on
      #   default logging on
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts enable [Boolean] Enables logging globally if value is
      #   true or disabled logging globally if value is false.
      #
      # @option opts default [Boolean] Configure the ip address value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_enable(opts = {})
        cmd = command_builder('logging on', opts)
        configure cmd
      end

      ##
      # set_console configures the global logging level for the console.
      # If the default keyword is specified and set to true, then the
      # configuration is defaulted using the default keyword. The default
      # keyword option takes precedence over the enable keyword if both
      # options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   logging console <level>
      #   no logging console <level>
      #   default logging console
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts level [Int|String] Enables logging at the specified
      #   level.  Accepts <0-7> and logging level keywords.
      #
      # @option opts default [Boolean] Resets the monitor level to the
      #   default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_console(opts = {})
        cmd = 'logging console'
        cmd += " #{opts[:level]}" if opts[:level]
        cmd = command_builder(cmd, opts)
        configure cmd
      end

      ##
      # set_monitor configures the global logging level for terminals
      # If the default keyword is specified and set to true, then the
      # configuration is defaulted using the default keyword. The default
      # keyword option takes precedence over the enable keyword if both
      # options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   logging monitor <level>
      #   no logging monitor <level>
      #   default logging monitor
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts level [Int|String] Enables logging at the specified
      #   level.  Accepts <0-7> and logging level keywords.
      #
      # @option opts default [Boolean] Resets the monitor level to the
      #   default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_monitor(opts = {})
        cmd = 'logging monitor'
        cmd += " #{opts[:level]}" if opts[:level]
        cmd = command_builder(cmd, opts)
        configure cmd
      end

      ##
      # set_time_stamp_units configures the global logging time_stamp_units
      # If the default keyword is specified and set to true, then the
      # configuration is defaulted using the default keyword. The default
      # keyword option takes precedence over the enable keyword if both
      # options are specified.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   logging format timestamp <traditional|high-resolution>
      #   no logging format timestamp <level>
      #   default logging format timestamp
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts units [String] Enables logging timestamps with the
      #   specified units. One of 'traditional' | 'seconds' or
      #   'high-resolution' | 'milliseconds'
      #
      # @option opts default [Boolean] Resets the logging timestamp level to
      #   the default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_time_stamp_units(opts = {})
        unit_map = {
          'traditional' => ' traditional',
          'seconds' => ' traditional',
          'high-resolution' => ' high-resolution',
          'milliseconds' => ' high-resolution'
        }
        units = ''
        units = unit_map[opts[:units]] if opts[:units]
        cmd = "logging format timestamp#{units}"
        cmd = command_builder(cmd, opts)
        configure cmd
      end

      ##
      # add_host configures a new logging destination host address or hostname
      # to the list of logging destinations. If the host is already configured
      # in the list of destinations, this method will return successfully.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   logging host <name>
      #
      # @param name [String] The host name or ip address of the destination
      #   node to send logging information to.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def add_host(name, opts = {})
        vrf = opts[:vrf] ? "vrf #{opts[:vrf]} " : ''
        cmd = "logging #{vrf}host #{name}"
        cmd += " #{opts[:port]}" if opts[:port]
        cmd += " protocol #{opts[:protocol]}" if opts[:protocol]
        configure cmd
      end

      ##
      # remove_host deletes a logging destination host name or address form the
      # list of logging destinations.  If the host is not in the list of
      # configured hosts, this method will still return successfully.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   no logging host <name>
      #
      # @param name [String] The host name or ip address of the destination
      #   host to remove from the nodes current configuration.
      #
      # @return [Boolean] Returns true if the commands completed successfully.
      def remove_host(name, opts = {})
        vrf = opts[:vrf] ? "vrf #{opts[:vrf]} " : ''
        # Hosts are uniquely identified by vrf and address, alone.
        cmd = "no logging #{vrf}host #{name}"
        configure cmd
      end
    end
  end
end
