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
    # The Ntp class provides an instance for working with the nodes
    # NTP configuration.
    class Ntp < Entity
      DEFAULT_SRC_INTF = ''

      ##
      # get returns the nodes current ntp configure as a resource hash
      #
      # @example
      #   {
      #     source_interface: <string>,
      #     servers: {
      #       prefer: [true, false]
      #     }
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] Returns the ntp resource as a
      #   Hash.
      def get
        response = {}
        response.merge!(parse_source_interface)
        response.merge!(parse_servers)
        response
      end

      ##
      # parse_source_interface scans the nodes configurations and parses
      # the ntp source interface if configured.  If the source interface
      # is not configured, this method will return DEFAULT_SRC_INTF as the
      # value. The return hash is intended to be merged into the resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_source_interface
        mdata = /(?<=^ntp\ssource\s)(.+)$/.match(config)
        { source_interface: mdata.nil? ? DEFAULT_SRC_INTF : mdata[1] }
      end
      private :parse_source_interface

      ##
      # parse_servers scans the nodes configuration and parses the configured
      # ntp server host names and/or addresses.  This method will also return
      # the value of prefer.  If no servers are configured, the value will be
      # set to an empty array.  The return hash is intended to be merged into
      # the resource hash
      #
      # @api private
      #
      # @return [Hash<Symbol, Object>] resource hash attribute
      def parse_servers
        servers = config.scan(/(?:ntp server\s)([^\s]+)\s(prefer)?/)
        values = servers.each_with_object({}) do |(srv, prefer), hsh|
          hsh[srv] = { prefer: !prefer.nil? }
        end
        { servers: values }
      end
      private :parse_servers

      ##
      # set_source_interface configures the ntp source value in the nodes
      # running configuration.  If the enable keyword is false, then
      # the ntp source is configured with the no keyword argument.  If the
      # default keyword argument is provided and set to true, the value is
      # configured used the default keyword.  The default keyword takes
      # precedence over the enable keyword if both options are specified.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   ntp source <value>
      #   no ntp source
      #   default ntp source
      #
      # @param [Hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The value to configure the ntp source
      #   in the nodes configuration
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the ntp source value using
      #   the default keyword
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_source_interface(opts = {})
        cmd = command_builder('ntp source', opts)
        configure(cmd)
      end

      ##
      # add_server configures a new ntp server destination hostname or ip
      # address to the list of ntp destinations.  The optional prefer argument
      # configures the server as a preferred (true) or not (false) ntp
      # destination.
      #
      # @param [String] :server The IP address or FQDN of the NTP server to
      #   be removed from the configuration
      #
      # @param [Boolean] :prefer Appends the prefer keyword argument to the
      #   command if this value is true
      #
      # @return [Boolean] returns true if the command completed successfully
      def add_server(server, prefer = false)
        cmd = "ntp server #{server}"
        cmd << ' prefer' if prefer
        configure cmd
      end

      ##
      # remove_server deletes the provided server destination from the list of
      # ntp server destinations.  If the ntp server does not exist in the list
      # of servers, this method will return successful
      #
      # @param [String] :server The IP address or FQDN of the NTP server to
      #   be removed from the configuration
      #
      # @return [Boolean] returns true if the command completed successfully
      def remove_server(server)
        configure("no ntp server #{server}")
      end

      ##
      # set_prefer will set the prefer keyword for the specified ntp server.
      # If the server does not already exist in the configuration, it will be
      # added and the prefer keyword will be set.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   ntp server <srv> prefer
      #   no ntp server <srv> prefer
      #
      # @param [String] :srv The IP address or hostname of the ntp server to
      #   configure with the prefer value
      #
      # @param [Boolean] :value The value to configure for prefer.  If true
      #   the prefer value is configured for the server.  If false, then the
      #   prefer value is removed.
      #
      # @return [Boolean] returns true if the commands completed successfully
      def set_prefer(srv, value)
        case value
        when true
          cmds = "ntp server #{srv} prefer"
        when false
          cmds = ["no ntp server #{srv} prefer", "ntp server #{srv}"]
        end
        configure cmds
      end
    end
  end
end
