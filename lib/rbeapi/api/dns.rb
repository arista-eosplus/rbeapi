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

    class Dns < Entity

      ##
      # Returns the DNS resource
      #
      # @example
      #   {
      #     "domain_name": <string>,
      #     "name_servers": array<strings>,
      #     "domain_list": array<strings>
      #   }
      #
      # @return [Hash]  A Ruby hash objec that provides the SNMP settings as
      #   key / value pairs.
      def get
        response = {}
        response.merge!(parse_domain_name)
        response.merge!(parse_name_servers)
        response.merge!(parse_domain_list)
        response
      end

      def parse_domain_name
        mdata = /ip domain-name ([\w.]+)/.match(config)
        { domain_name: mdata.nil? ? '' : mdata[1] }
      end

      def parse_name_servers
        servers = config.scan(/(?:ip name-server vrf )(?:\w+)\s(.+)/)
        values = servers.each_with_object([]) { |srv, arry| arry << srv.first }
        { name_servers: values }
      end

      def parse_domain_list
        search = config.scan(/(?<=^ip\sdomain-list\s).+$/)
        { domain_list: search }
      end

      ##
      # Configure the domain-name value in the running-config
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The value to set the domain-name to
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_domain_name(opts = {})
        value = opts[:value]
        default = opts[:default] || false

        case default
        when true
          cmds = 'default ip domain-name'
        when false
          cmds = (value ? "ip domain-name #{value}" : 'no ip domain-name')
        end
        configure(cmds)
      end

      def add_name_server(server)
        configure "ip name-server #{server}"
      end

      def remove_name_server(server)
        configure "no ip name-server #{server}"
      end

      def add_domain_list(name)
        configure "ip domain-list #{name}"
      end

      def remove_domain_list(name)
        configure "no ip domain-list #{name}"
      end
    end
  end
end
