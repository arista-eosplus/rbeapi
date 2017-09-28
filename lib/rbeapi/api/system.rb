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
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The System class configures the node system services such as
    # hostname and domain name.
    class System < Entity
      def initialize(node)
        super(node)
        @banners_re = Regexp.new(/^banner\s+(login|motd)\s?$\n(.*?)$\nEOF$\n/m)
      end

      ##
      # Returns the system settings for hostname, iprouting, and banners.
      #
      # @example
      #   {
      #     hostname: <string>,
      #     iprouting: <boolean>,
      #     banner_motd: <string>,
      #     banner_login: <string>
      #   }
      #
      # @return [Hash] A Ruby hash object that provides the system settings as
      #   key/value pairs.
      def get
        response = {}
        response.merge!(parse_hostname(config))
        response.merge!(parse_iprouting(config))
        response.merge!(parse_timezone(config))
        response.merge!(parse_banners(config))
        response.merge!(parse_vrf_routing(config))
        response
      end

      ##
      # parse_hostname parses hostname values from the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] The resource hash attribute.
      def parse_hostname(config)
        mdata = /(?<=^hostname\s)(.+)$/.match(config)
        { hostname: mdata.nil? ? '' : mdata[1] }
      end
      private :parse_hostname

      ##
      # parse_iprouting parses ip routing from the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] The resource hash attribute.
      def parse_iprouting(config)
        mdata = /no\sip\srouting$/.match(config)
        { iprouting: mdata.nil? ? true : false }
      end
      private :parse_iprouting

      ##
      # parse_vrf_routing parses ip routing from the provided config.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] Hash keyed on VRF name. values: true | false
      def parse_vrf_routing(config)
        mdata = config.scan(/^(no)?\s?ip\srouting\svrf\s(\w+)/)
        vrfs = {}
        mdata.each do |match,vrf|
          vrfs[vrf] = match.nil? ? true : false
        end
        { vrf_routing: vrfs }
      end
      private :parse_vrf_routing

      ##
      # parse_timezone parses the value of clock timezone.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] The resource hash attribute.
      def parse_timezone(config)
        mdata = /(?<=^clock timezone\s)(.+)$/.match(config)
        { timezone: mdata.nil? ? '' : mdata[1] }
      end
      private :parse_timezone

      ##
      # Parses the global config and returns the value for both motd
      # and login banners.
      #
      # @api private
      #
      # @param config [String] The configuration block returned
      #   from the node's running configuration.
      #
      # @return [Hash<Symbol, Object>] The resource hash attribute. If the
      #   banner is not set it will return a value of None for that key.
      def parse_banners(config)
        motd_value = login_value = ''
        entries = config.scan(@banners_re)
        entries.each do |type, value|
          if type == 'motd'
            motd_value = value
          elsif type == 'login'
            login_value = value
          end
        end
        { banner_motd: motd_value, banner_login: login_value }
      end
      private :parse_banners

      ##
      # Configures the system hostname value in the running-config.
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts value [string] The value to set the hostname to.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] If true configure the command using
      #   the default keyword. Default is false.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_hostname(opts = {})
        cmd = command_builder('hostname', opts)
        configure(cmd)
      end

      ##
      # Configures the state of global ip routing.
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts enable [Boolean] True if ip routing should be enabled
      #  or False if ip routing should be disabled. Default is true.
      #
      # @option opts default [Boolean] If true configure the command using
      #   the default keyword. Default is false.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_iprouting(opts = {})
        cmd = command_builder('ip routing', opts)
        configure(cmd)
      end

      ##
      # Configures the state of vrf ip routing.
      #
      # @param vrf [String] The VRF name
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts enable [Boolean] True if ip routing should be enabled
      #  or False if ip routing should be disabled. Default is true.
      #
      # @option opts default [Boolean] If true configure the command using
      #   the default keyword. Default is false.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      #
      # @example
      #     system.set_vrf_routing('red', enable: true)
      #     system.set_vrf_routing('blue', enable: false)
      #     system.set_vrf_routing('green', enable: true)
      #
      def set_vrf_routing(vrf, opts = {})
        cmd = command_builder("ip routing vrf #{vrf}", opts)
        configure(cmd)
      end


      ##
      # Configures the value of clock timezone in the running-config.
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts value [string] The value to set the clock timezone to.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] If true configure the command using
      #   the default keyword. Default is false.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_timezone(opts = {})
        cmd = command_builder('clock timezone', opts)
        configure(cmd)
      end

      ##
      # Configures system banners.
      #
      # @param banner_type [String] Banner to be changed (likely either
      #   login or motd).
      #
      # @param opts [Hash] The configuration parameters.
      #
      # @option opts value [string] The value to set for the banner.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] If true configure the command using
      #   the default keyword. Default is false.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_banner(banner_type, opts = {})
        value = opts[:value]
        cmd_string = "banner #{banner_type}"
        if value
          value += "\n" if value[-1, 1] != "\n"
          cmd = [{ cmd: cmd_string, input: value }]
        else
          cmd = command_builder(cmd_string, opts)
        end
        configure(cmd)
      end
    end
  end
end
