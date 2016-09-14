#
# Copyright (c) 2016, Arista Networks, Inc.
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
    # The Iphosts class manages hosts entries on an EOS node.
    class Iphosts < Entity

      ##
      # get returns the current ip host configuration hash extracted from the
      # nodes running configuration.
      #
      # @example
      #   {
      #     hosts: array<strings>
      #   }
      #
      # @return [Hash<Symbol, Object>] Returns the ip host resource as a hash
      #   object from the nodes current configuration.
      def get(name)
        iphost = config.scan(/^ip host #{name} (\d+\.\d+\.\d+\.\d+)/)
        return nil unless iphost && iphost[0]
        parse_host_entry(name,iphost[0])
      end

      ##
      # getall returns a collection of ip host resource hashes from the nodes
      # running configuration. The ip host resource collection hash is keyed
      # by the unique host name.
      #
      # @example
      #   [
      #     <host>: {
      #       ipaddress: <string>
      #     },
      #     <host>: {
      #       ipaddress: <string>
      #     },
      #     ...
      #   ]
      #
      # @return [Hash<Symbol, Object>] Returns a hash that represents the
      #   entire ip host collection from the nodes running configuration.  If
      #   there are no ip hosts configured, this method will return an empty
      #   hash.
      def getall
        entries = config.scan(/^ip host ([^\s]+) (\d+\.\d+\.\d+\.\d+)/)
        response = {}
        entries.each do |host|
          response[host[0]] = get host[0]
        end
        response
      end

      ##
      # parse_host_entry maps the tokens found to the hash entries.
      #
      # @api private
      #
      # @param host [Array] An array of values returned from the regular
      #   expression scan of the hosts configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_host_entry(host,ipaddress)
        hsh = {}
        hsh[:name] = host
        hsh[:ipaddress] = ipaddress[0]
        hsh
      end
      private :parse_host_entry

      ##
      # create will create a ip host entry in the nodes current
      # configuration with the specified address.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   ip host <name> <address>
      #
      # @param name [String] The name of the host.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts ipaddress [String] Configures the host ip address
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(name, opts = {})
        if (/(\d+\.\d+\.\d+\.\d+)/).match(opts[:ipaddress])
          cmd = "ip host #{name} #{opts[:ipaddress]}"
          configure(cmd)
        else
          fail ArgumentError, 'option ipaddress must be a valid IP'
        end
      end

      ##
      # delete will delete an existing ip host entry from the nodes current
      # running configuration. If the delete method is called and the host
      # entry does not exist, this method will succeed.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   no ip host <name>
      #
      # @param name [String] The host name entry to delete from the node.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(name)
        configure("no ip host #{name}")
      end

    end
  end
end
