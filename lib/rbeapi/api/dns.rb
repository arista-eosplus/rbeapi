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
    # The Dns class manages DNS settings on an EOS node.
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
      # @return [Hash]  A Ruby hash object that provides the SNMP settings as
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
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option opts [Boolean] :default The value should be set to default
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_domain_name(opts = {})
        cmds = command_builder('ip domain-name', opts)
        configure(cmds)
      end

      ##
      # set_name_servers configures the set of name servers that eos will use
      # to resolve dns queries. If the enable option is false, then the
      # name-server list will be configured using the no keyword.  If the
      # default option is specified, then the name server list will be
      # configured using the default keyword.  If both options are provided the
      # keyword option will take precedence
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   ip name-server <value>
      #   no ip name-server
      #   default ip name-server
      #
      # @param [Hash] opts The configuration parameters
      # @option opts [string] :value The set of name servers to configure on the
      #   node.  The list of name servers will be replace in the nodes running
      #   configuration by the list provided in value
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      # @option [Boolean] :default Configures the ip name-servers using the
      #   default keyword argument. Default takes precedence over enable.
      #
      # @return [Boolean] returns true if the commands completed successfully
      def set_name_servers(opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        case default
        when true
          cmds = 'default ip name-server'
        when false
          cmds = ['no ip name-server']
          if enable
            value.each do |srv|
              cmds << "ip name-server #{srv}"
            end
          end
        end
        configure cmds
      end

      def add_name_server(server)
        configure "ip name-server #{server}"
      end

      def remove_name_server(server)
        configure "no ip name-server #{server}"
      end

      ##
      # set_domain_list configures the set of domain names to search when
      # making dns queries for the FQDN.  If the enable option is set to false,
      # then the domain-list will be configured using the no keyword.  If the
      # default option is specified, then the domain list will be configured
      # using the default keyword.  If both options are provided the default
      # keyword option will take precedence.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   ip domain-list <value>
      #   no ip domain-list
      #   default ip domain-list
      #
      # @option [Array] :value The set of domain names to configure on the
      #   node.  The list of domain names will be replace in the nodes running
      #   configuration by the list provided in value
      #
      # @option [Boolean] :default Configures the ip domain-list using the
      #   default keyword argument
      #
      # @return [Boolean] returns true if the commands completed successfully
      def set_domain_list(opts = {})
        value = opts[:value]
        enable = opts.fetch(:enable, true)
        default = opts[:default] || false

        cmds = []
        case default
        when true
          parse_domain_list[:domain_list].each do |name|
            cmds << "default ip domain-list #{name}"
          end
        when false
          parse_domain_list[:domain_list].each do |name|
            cmds << "no ip domain-list #{name}"
          end
          if enable
            value.each do |name|
              cmds << "ip domain-list #{name}"
            end
          end
        end
        configure cmds
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
