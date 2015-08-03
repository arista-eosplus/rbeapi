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
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::Api
  module Api
    ##
    # The Staticroutes class provides a configuration instance for working
    # with static routes in EOS.
    #
    class Staticroutes < Entity
      ##
      # Returns the static routes configured on the node
      #
      # @example
      #   {
      #     <route_dest/masklen/next_hop>: {
      #       "distance": <integer>,
      #       "tag": <integer>,
      #       "name": <string, nil>
      #     }
      #   }
      #
      # @returns [Hash<String, String> The method will return all of the
      #   configured static routes on the node as a Ruby hash object.  If
      #   there are no static routes configured, this method will return
      #   an empty hash
      def getall
        regex = /
          (?<=^ip\sroute\s)
          ([^\s]+)\s                # capture destination
          ([^\s$]+)                 # capture next hop IP or egress interface
          [\s|$](\d+)               # capture metric (distance)
          [\s|$]{1}(?:tag\s(\d+))?  # catpure route tag
          [\s|$]{1}(?:name\s(.+))?  # capture route name
        /x

        routes = config.scan(regex)

        routes.each_with_object({}) do |route, hsh|
          hsh[route[0] << '/' << route[1]] = {
            distance: route[2],
            tag: route[3],
            name: route[4] }
        end
      end

      def create(route, nexthop, opts = {})
        cmd = "ip route #{route} #{nexthop}"
        cmd << " #{opts[:router_ip]}" if opts[:router_ip]
        cmd << " #{opts[:distance]}" if opts[:distance]
        cmd << " tag #{opts[:tag]}" if opts[:tag]
        cmd << " name #{opts[:name]}" if opts[:name]
        configure cmd
      end

      def delete(route, nexthop = nil)
        cmd = "no ip route #{route}"
        cmd << " #{nexthop}" if nexthop
        configure cmd
      end
    end
  end
end
