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

##
# Eos is the toplevel namespace for working with Arista EOS nodes
module Rbeapi
  ##
  # Api is module namesapce for working with the EOS command API
  module Api

    ##
    # The Ntp class provides an intstance for working with the nodes
    # NTP configuraiton.
    class Ntp < Entity

      ##
      # Returns the NTP configuration from the nodes running configuration
      #
      # Example
      #   {
      #     "source_interface": <string>,
      #     "servers": array<string>
      #   }
      #
      # @return [Hash] Returns a Ruby hash object with the NTP configuration
      #   from the node as key/value pairs
      def get
        response = {}
        response.merge!(parse_source_interface)
        response.merge!(parse_servers)
        response
      end

      def parse_source_interface
        mdata = /(?<=^ntp\ssource\s)(.+)$/.match(config)
        { source_interface: mdata.nil? ? '' : mdata[1] }
      end

      def parse_servers
        servers = config.scan(/(?:ntp server\s)([^\s]+)\s(prefer)?/)
        values = servers.each_with_object({}) do |(srv, prefer), hsh|
          hsh[srv] = { prefer: !prefer.nil? }
        end
        { servers: values }
      end

      ##
      # Configures the source interface for sending NTP packets from the node
      #
      # @param [String] :value The value to configure the source interface
      #  value to
      # @param [Boolean] :default Specifies the value should be defaulted
      #
      # @return [Boolean] True if the commands complete successfully otherwise
      #   False
      def set_source_interface(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = 'default ntp source'
        when false
          cmds = (value ? "ntp source #{value}" : \
                          'no ntp source')
        end
        configure(cmds)
      end

      ##
      # Adds the specified NTP server to the nodes configuration.
      #
      # @param [String] :server The IP address or FQDN of the NTP server to
      #   be removed from the configuration
      # @param [Boolean] :prefer Appends the prefer keyword argument to the
      #   command if this value is true
      #
      # @return [Boolean] True if the commands complete successfully otherwise
      #   False
      def add_server(server, prefer = false)
        cmd = "ntp server #{server}"
        cmd << ' prefer' if prefer
        configure cmd
      end

      ##
      # Removes the specified NTP server from the nodes configuration.
      #
      # @param [String] :server The IP address or FQDN of the NTP server to
      #   be removed from the configuration
      #
      # @return [Boolean] True if the commands complete successfully otherwise
      #   False
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
