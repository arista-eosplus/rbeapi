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
    # The Routemaps class manages routemaps. A route map is a list of rules
    # that control the redistribution of IP routes into a protocol domain on
    # the basis of such criteria as route metrics, access control lists, next
    # hop addresses, and route tags.
    #
    class Routemaps < Entity
      ##
      # get returns a hash of routemap configurations for the given name
      #
      # @example
      #   {
      #     [{
      #       action: <string>,
      #       seqno: <integer>,
      #       match: <array>,
      #       set: <array>,
      #       continue: <integer>,
      #       description: <string>
      #     },
      #     {
      #       action: <string>,
      #       seqno: <integer>,
      #       match: <array>,
      #       set: <array>,
      #       continue: <integer>,
      #       description: <string>
      #     }]
      #   }
      #
      # @param [String] name The routemap name to return a resource for from the
      #   nodes configuration
      #
      # @return [nil, Hash<Symbol, Object>] Returns the routemap resource as a
      #   Hash. If the specified name is not found in the nodes current
      #   configuration a nil object is returned
      def get(name)
        parse_entries(name)
      end

      ##
      # getall returns a collection of routemap resource hashes from the nodes
      # running configuration. The routemap resource collection hash is keyed
      # by the unique routemap name.
      #
      # @example
      #   {
      #     <test>:
      #     [{
      #       action: <string>,
      #       seqno: <integer>,
      #       match: <array>,
      #       set: <array>,
      #       continue: <integer>,
      #       description: <string>
      #     },
      #     {
      #       action: <string>,
      #       seqno: <integer>,
      #       match: <array>,
      #       set: <array>,
      #       continue: <integer>,
      #       description: <string>
      #     }],
      #     <test1>:
      #     [{
      #       action: <string>,
      #       seqno: <integer>,
      #       match: <array>,
      #       set: <array>,
      #       continue: <integer>,
      #       description: <string>
      #     }],
      #     ....
      #   }
      #
      # @return [Hash<Symbol, Object>] returns a hash that represents the
      #   entire routemap collection from the nodes running configuration.  If
      #   there are no routemap names configured, this method will return an
      #   empty hash.
      def getall
        routemaps = config.scan(/(?<=^route-map\s)[^\s]+/)
        return nil unless routemaps
        response = {}
        routemaps.each do |name|
          response[name] = parse_entries(name)
        end
        response
      end

      ##
      # parse entries is a private method to get the routemap rules.
      #
      # @return [Hash<Symbol, Object>] returns a hash that represents the
      #   rules for routemaps from the nodes running configuration.  If
      #   there are no routemaps configured, this method will return an empty
      #   hash.
      #
      def parse_entries(name)
        entries = config.scan(/^route-map\s#{name}\s.+$/)
        response = {}
        response[:entries] = []
        entries.each_with_object({}) do |rm|
          mdata = /^route-map\s(.+)\s(.+)\s(\d+)$/.match(rm)
          rules = get_block(rm)
          rule_hsh = { action: mdata[2], seqno: mdata[3].to_i }
          unless rules.nil?
            rules.split("\n").each_with_object({}) do |rule|
              parse_rule(rule, rule_hsh)
            end
          end
          response[:entries] << rule_hsh
        end
        response[:entries]
      end
      private :parse_entries

      ##
      # parse rule is a private method to parse a rule.
      #
      # @return [Hash<Symbol, Object>] returns a hash that represents the
      #   rules for routemaps from the nodes running configuration.  If
      #   there are no routemaps configured, this method will return an empty
      #    hash.
      #
      def parse_rule(rule, rule_hsh)
        mdata = /\s{3}(\w+)\s/.match(rule)
        case mdata.nil? ? nil : mdata[1]
        when 'match'
          rule_hsh[:match] = [] unless rule_hsh.include?(:match)
          rule_hsh[:match] << rule.sub('match', '').strip
        when 'set'
          rule_hsh[:set] = [] unless rule_hsh.include?(:set)
          rule_hsh[:set] << rule.sub('set', '').strip
        when 'continue'
          rule_hsh[:continue] = nil unless rule_hsh.include?(:continue)
          rule_hsh[:continue] = rule.sub('continue', '').strip.to_i
        when 'description'
          rule_hsh[:description] = nil unless rule_hsh.include?(:description)
          rule_hsh[:description] = rule.sub('description', '').strip
        end
      end
      private :parse_rule

      ##
      # name_commands is utilized by create to prepare the specified
      # routemap.
      def name_commands(name, action, seqno, opts = {})
        if opts
          if opts[:default] == true
            cmd = "default route-map #{name}"
          elsif opts[:enable] == false
            cmd = "no route-map #{name}"
          else
            cmd = "route-map #{name}"
          end
          cmd << " #{action}"
          cmd << " #{seqno}"
        else
          cmd = "route-map #{name}"
        end
        [cmd]
      end
      private :name_commands

      ##
      # create will create a new routemap with the specified name.
      #
      # @commands
      #   route-map <name> action <value> seqno <value> description <value>
      #   match <value> set <value> continue <value>
      #
      # @param [String] :name The name of the routemap to create
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :default Set routemap to default
      #
      # @option :opts [String] :description A description for the routemap
      #
      # @option :opts [Array] :match routemap match rule
      #
      # @option :opts [String] :set Sets route attribute
      #
      # @option :opts [String] :continue The routemap sequence number to
      #   continue on.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the routemap to default.
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(name, action, seqno, opts = {})
        if opts.empty?
          cmds = name_commands(name, action, seqno)
        else
          cmds = name_commands(name, action, seqno, opts)
          if opts[:description]
            cmds << 'no description'
            cmds << "description #{opts[:description]}"
          end
          if opts[:continue]
            cmds << 'no continue'
            cmds << "continue #{opts[:continue]}"
          end
          remove_match_statements(name, action, seqno, cmds)
          Array(opts[:match]).each do |options|
            cmds << "match #{options}"
          end
          remove_set_statements(name, action, seqno, cmds)
          Array(opts[:set]).each do |options|
            cmds << "set #{options}"
          end
        end
        configure(cmds)
      end

      ##
      # remove_match_statemements removes all match rules for the
      # specified routemap
      def remove_match_statements(name, action, seqno, cmds)
        entries = parse_entries(name)
        return true unless entries
        entries.each do |entry|
          next unless entry[:action] == action && entry[:seqno] == seqno
          Array(entry[:match]).each do |options|
            cmds << "no match #{options}"
          end
        end
      end
      private :remove_match_statements

      ##
      # remove_set_statemements removes all set rules for the
      # specified routemap
      def remove_set_statements(name, action, seqno, cmds)
        entries = parse_entries(name)
        return true unless entries
        entries.each do |entry|
          next unless entry[:action] == action && entry[:seqno] == seqno
          Array(entry[:set]).each do |options|
            cmds << "no set #{options}"
          end
        end
      end
      private :remove_set_statements

      ##
      # delete will delete an existing routemap name from the nodes current
      # running configuration. If the delete method is called and the
      # routemap name does not exist, this method will succeed.
      #
      # @commands
      #   no route-map <name>
      #
      # @param [String] :name The routemap name to delete from the node.
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(name)
        configure(["no route-map #{name}"])
      end

      ##
      # This method will attempt to default the routemap from the nodes
      # operational config. Since routemaps do not exist by default,
      # the default action is essentially a negation and the result will
      # be the removal of the routemap clause.
      # If the routemap does not exist then this
      # method will not perform any changes but still return True
      #
      # @commands
      #   no route-map <name>
      #
      # @param [String] :name The routemap name to set to default.
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @return [Boolean] returns true if the command completed successfully
      def default(name, action, seqno)
        cmds = []
        cmds << "default route-map #{name}"
        cmd << " #{action}"
        cmd << " #{seqno}"
        configure(cmds)
      end

      ##
      # set_match_statements will set the match values for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # @commands
      #   route-map <name> action <value> seqno <value> match <value>
      #
      # @param [String] :name The name of the routemap to create
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @param [Array] :value The routemap match rules
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_match_statements(name, action, seqno, value)
        cmd = "route-map #{name}"
        cmd << " #{action}"
        cmd << " #{seqno}"
        cmds = [cmd]
        remove_match_statements(name, action, seqno, cmds)
        Array(value).each do |options|
          cmds << "match #{options}"
        end
        configure(cmds)
      end

      ##
      # set_set_statements will set the set values for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # @commands
      #   route-map <name> action <value> seqno <value> set <value>
      #
      # @param [String] :name The name of the routemap to create
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @param [Array] :value The routemap set rules
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_set_statements(name, action, seqno, value)
        cmd = "route-map #{name}"
        cmd << " #{action}"
        cmd << " #{seqno}"
        cmds = [cmd]
        remove_set_statements(name, action, seqno, cmds)
        Array(value).each do |options|
          cmds << "set #{options}"
        end
        configure(cmds)
      end

      ##
      # set_continue will set the continue value for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # @commands
      #   route-map <name> action <value> seqno <value> continue <value>
      #
      # @param [String] :name The name of the routemap to create
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @param [Integer] :value The continue value
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_continue(name, action, seqno, value)
        cmd = "route-map #{name}"
        cmd << " #{action}"
        cmd << " #{seqno}"
        cmds = [cmd]
        cmds << 'no continue'
        cmds << "continue #{value}"
        configure(cmds)
      end

      ##
      # set_description will set the description for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # @commands
      #   route-map <name> action <value> seqno <value> description <value>
      #
      # @param [String] :name The name of the routemap to create
      #
      # @param [String] :action Either permit or deny
      #
      # @param [Integer] :seqno The sequence number
      #
      # @param [String] :value The description value
      #
      # @return [Boolean] returns true if the command completed successfully
      def set_description(name, action, seqno, value)
        cmd = "route-map #{name}"
        cmd << " #{action}"
        cmd << " #{seqno}"
        cmds = [cmd]
        cmds << 'no description'
        cmds << "description #{value}"
        configure(cmds)
      end
    end
  end
end
