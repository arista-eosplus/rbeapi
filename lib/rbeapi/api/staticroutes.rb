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

    ##
    # The Staticroute class provides a configuration instance for working
    # with static routes in EOS.
    #
    class Staticroute < Entity

      ##
      # Returns the static routes configured on the node
      #
      # @example
      #   {
      #     <route>: {
      #       "next_hop": <string>,
      #       "name": <string, nil>
      #     }
      #   }
      #
      # @returns [Hash<String, String> The method will return all of the
      #   configured static routes on the node as a Ruby hash object.  If
      #   there are no static routes configured, this method will return
      #   an empty hash
      def getall
        regex = %r{
          (?<=^ip\sroute\s)
          ([^\s]+)\s                # captures network
          ([^\s$]+)                 # captures next hop
          (?:\s\d+)                 # non-capture metric
          (?:\stag\s\d+)            # non-catpure route tag
          [\s|$]{1}(?:name\s(.+))?  # capture route name
        }x

        routes = config.scan(regex)

        routes.each_with_object({}) do |route, hsh|
          hsh[route[0]] = { 'next_hop' => route[1],
                            'name' => route[2] }
        end
      end

      def create(route, nexthop, opts = {})
        cmd = "ip route #{route} #{nexthop}"
        opts.each { |param, value| cmds << "#{param} #{value}" }
        configure cmd
      end

      def delete(route)
        configure "no ip route #{route}"
      end
    end
  end
end
