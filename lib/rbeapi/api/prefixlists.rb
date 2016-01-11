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
  # Api is module namespace for working with the EOS command API
  module Api
    ##
    # The Prefixlists class provides a configuration instance for working
    # with static routes in EOS.
    #
    class Prefixlists < Entity
      ##
      # Returns the static routes configured on the node
      #
      # @example
      #   {
      #     <route>: {
      #       next_hop: <string>,
      #       name: <string, nil>
      #     }
      #   }
      #
      # @param [String] :name The name of the prefix-list to return
      #
      # @returns [Hash<String, String> The method will return all of the
      #   configured static routes on the node as a Ruby hash object.  If
      #   there are no static routes configured, this method will return
      #   an empty hash
      def get(name)
        config = get_block("ip prefix-list #{name}")
        return nil unless config

        entries = config.scan(/^\s{3}(?:seq\s)(\d+)\s(permit|deny)\s(.+)$/)
        entries.each_with_object([]) do |entry, arry|
          arry << { 'seq' => entry[0], 'action' => entry[1],
                    'prefex' => entry[2] }
        end
      end

      ##
      # Returns the static routes configured on the node
      #
      # @example
      #   {
      #     <route>: {
      #       next_hop: <string>,
      #       name: <string, nil>
      #     }
      #   }
      #
      # @returns [Hash<String, String> The method will return all of the
      #   configured static routes on the node as a Ruby hash object.  If
      #   there are no static routes configured, this method will return
      #   an empty hash
      def getall
        lists = config.scan(/(?<=^ip\sprefix-list\s).+/)
        lists.each_with_object({}) do |name, hsh|
          values = get name
          hsh[name] = values if values
        end
      end

      ##
      # create will create a new ip prefix-list with designated name.
      #
      # @param [String] :name The name of the ip prefix-list
      # 
      # @return [Boolean] returns true if the command completed successfully
      def create(name)
        configure "ip prefix-list #{name}"
      end

      ##
      # add_rule will create an ip prefix-list with the designated name,
      #   seqno, action and prefix.
      #
      # @param [String] :name The name of the ip prefix-list
      #
      # @param [String] :seq The seq value
      #
      # @param [String] :action The action value
      #
      # @param [String] :prefix The prefix value
      # 
      # @return [Boolean] returns true if the command completed successfully
      def add_rule(name, action, prefix, seq = nil)
        cmd = "ip prefix-list #{name}"
        cmd << " seq #{seq}" if seq
        cmd << " #{action} #{prefix}"
        configure cmd
      end

      ##
      # delete will remove the designated prefix-list
      #
      # @param [String] :name The name of the ip prefix-list
      #
      # @param [String] :seq The seq value
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(name, seq = nil)
        cmd = "no ip prefix-list #{name}"
        cmd << " seq #{seq}" if seq
        configure cmd
      end
    end
  end
end
