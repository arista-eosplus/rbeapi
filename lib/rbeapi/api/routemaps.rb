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

    class Routemaps < Entity

      def get(name)
        entries = config.scan(/^route-map\s#{name}\s.+$/)

        entries.each_with_object([]) do |rm, arry|
          mdata = /route-map\s(.+)\s(.+)\s(\d+)$/.match(rm)
          rules = get_block(rm)
          rule_hsh = { 'action' => mdata[2], 'seqno' => mdata[3],
                       'match_rules' => [], 'set_rules' => [],
                       'continue_rules' => [] }

          parsed = rules.split("\n").each_with_object({}) do |rule, hsh|
            mdata = /\s{3}(\w+)\s/.match(rule)
            case mdata.nil? ? nil : mdata[1]
            when 'match'
              hsh['match_rules'] = [] unless hsh.include?('match')
              hsh['match_rules'] << rule.strip()
            when 'set'
              hsh['set_rules'] = [] unless hsh.include?('set')
              hsh['set_rules'] << rule.strip()
            when 'continue'
              hsh['continue_rules'] = [] unless hsh.include?('continue')
              hsh['continue_rules'] << rule.strip()
            end
          end
          rule_hsh.update(parsed)
          arry << rule_hsh
        end
      end

      def getall
        maps = config.scan(/(?<=^route-map\s)[^\s]+/)
        maps.each_with_object({}) do |name, hsh|
          if !hsh.include?(name)
            hsh[name] = get name
          end
        end
      end

      def create(name)
        configure "route-map #{name}"
      end

      def delete(name)
        configure "no route-map #{name}"
      end

      def add_rule(name, action, rule, seqno = nil)
        cmd = "route-map #{name} #{action}"
        cmd << " #{seqno}" if seqno
        cmds = [*cmds]
        cmds << rule
        configure cmds
      end

      def remove_rule(name, action, seqno)
        configure "no route-map #{name} #{action} #{seqno}"
      end

    end
  end
end
