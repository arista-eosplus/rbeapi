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
# Rbeapi toplevel namespace.
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The Routemaps class manages routemaps. A route map is a list of rules
    # that control the redistribution of IP routes into a protocol domain on
    # the basis of such criteria as route metrics, access control lists, next
    # hop addresses, and route tags.
    #
    # rubocop:disable Metrics/ClassLength
    #
    class Routemaps < Entity
      ##
      # get returns a hash of routemap configurations for the given name.
      #
      # @example
      #   {
      #     <action>: {
      #       <seqno>: {
      #         match: <array>,
      #         set: <array>,
      #         continue: <integer>,
      #         description: <string>
      #       },
      #       <seqno>: {
      #         match: <array>,
      #         set: <array>,
      #         continue: <integer>,
      #         description: <string>
      #       }
      #     },
      #     <action>: {
      #       <seqno>: {
      #         match: <array>,
      #         set: <array>,
      #         continue: <integer>,
      #         description: <string>
      #       },
      #       <seqno>: {
      #         match: <array>,
      #         set: <array>,
      #         continue: <integer>,
      #         description: <string>
      #       }
      #     }
      #   }
      #
      # @param name [String] The routemap name to return a resource for from
      #   the nodes configuration.
      #
      # @return [nil, Hash<Symbol, Object>] Returns the routemap resource as a
      #   Hash. If the specified name is not found in the nodes current
      #   configuration a nil object is returned.
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
      #     <name>: {
      #       <action>: {
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         },
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         }
      #       },
      #       <action>: {
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         },
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         }
      #       }
      #     },
      #     <name>: {
      #       <action>: {
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         },
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         }
      #       },
      #       <action>: {
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         },
      #         <seqno>: {
      #           match: <array>,
      #           set: <array>,
      #           continue: <integer>,
      #           description: <string>
      #         }
      #       }
      #     }
      #   }
      #
      # @return [nil, Hash<Symbol, Object>] Returns a hash that represents the
      #   entire routemap collection from the nodes running configuration. If
      #   there are no routemap names configured, this method will return nil.
      def getall
        routemaps = config.scan(/(?<=^route-map\s)[^\s]+/)
        return nil if routemaps.empty?
        routemaps.each_with_object({}) do |name, response|
          response[name] = parse_entries(name)
        end
      end

      ##
      # parse entries is a private method to get the routemap rules.
      #
      # @api private
      #
      # @param name [String] The routemap name.
      #
      # @return [nil, Hash<Symbol, Object>] Returns a hash that represents the
      #   rules for routemaps from the nodes running configuration. If
      #   there are no routemaps configured, this method will return nil.
      def parse_entries(name)
        entries = config.scan(/^route-map\s#{name}\s.+$/)
        return nil if entries.empty?
        entries.each_with_object({}) do |rm, response|
          mdata = /^route-map\s(.+)\s(.+)\s(\d+)$/.match(rm)
          rule_hsh = parse_rules(get_block(rm))
          if response[mdata[2]]
            response[mdata[2]].merge!(mdata[3].to_i => rule_hsh)
          else
            response[mdata[2]] = { mdata[3].to_i => rule_hsh }
          end
        end
      end
      private :parse_entries

      ##
      # parse rule is a private method to parse a rule.
      #
      # @api private
      #
      # @param rules [Hash] Rules configuration options.
      #
      # @option rules match [Array] The match options.
      #
      # @option rules set [Array] The set options.
      #
      # @option rules continue [String] The continue value.
      #
      # @option rules description [String] The description value.
      #
      # @return [Hash<Symbol, Object>] Returns a hash that represents the
      #   rules for routemaps from the nodes running configuration. If
      #   there are no routemaps configured, this method will return an empty
      #   hash.
      def parse_rules(rules)
        rules.split("\n").each_with_object({}) do |rule, rule_hsh|
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
      end
      private :parse_rules

      ##
      # name_commands is utilized to initially prepare the routemap.
      #
      # @param name [String] The routemap name.
      #
      # @param action [String] The action value.
      #
      # @param seqno [String] The seqno value.
      #
      # @param opts [Hash] The configuration options.
      #
      # @option opts default [Boolean] The default value.
      #
      # @option opts enable [Boolean] The enable value.
      #
      # @return [Array] Returns the prepared eos command.
      def name_commands(name, action, seqno, opts = {})
        cmd = if opts[:default] == true
                "default route-map #{name}"
              elsif opts[:enable] == false
                "no route-map #{name}"
              else
                "route-map #{name}"
              end
        cmd << " #{action}"
        cmd << " #{seqno}"
        [cmd]
      end
      private :name_commands

      ##
      # create will create a new routemap with the specified name.
      #
      # rubocop:disable Metrics/MethodLength
      #
      # ===Commands
      #   route-map <name> action <value> seqno <value> description <value>
      #   match <value> set <value> continue <value>
      #
      # @param name [String] The name of the routemap to create.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number value.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts default [Boolean] Set routemap to default.
      #
      # @option opts description [String] A description for the routemap.
      #
      # @option opts match [Array] routemap match rule.
      #
      # @option opts set [String] Sets route attribute.
      #
      # @option opts continue [String] The routemap sequence number to
      #   continue on.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the routemap to default.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(name, action, seqno, opts = {})
        if opts.empty?
          cmds = name_commands(name, action, seqno)
        else
          if opts[:match] && !opts[:match].is_a?(Array)
            raise ArgumentError, 'opts match must be an Array'
          end
          cmds = name_commands(name, action, seqno, opts)
          if opts[:description]
            cmds << 'no description'
            cmds << "description #{opts[:description]}"
          end
          if opts[:continue]
            cmds << 'no continue'
            cmds << "continue #{opts[:continue]}"
          end
          if opts[:match]
            remove_match_statements(name, action, seqno, cmds)
            opts[:match].each do |options|
              cmds << "match #{options}"
            end
          end
          if opts[:set]
            remove_set_statements(name, action, seqno, cmds)
            opts[:set].each do |options|
              cmds << "set #{options}"
            end
          end
        end
        configure(cmds)
      end

      ##
      # remove_match_statemements removes all match rules for the
      # specified routemap
      #
      # @param name [String] The routemap name.
      #
      # @param action [String] The action value.
      #
      # @param seqno [String] The seqno value.
      #
      # @param cmds [Array] Array of eos commands.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def remove_match_statements(name, action, seqno, cmds)
        raise ArgumentError, 'cmds must be an Array' unless cmds.is_a?(Array)

        entries = parse_entries(name)
        return nil unless entries
        entries.each do |entry|
          next unless entry[0] == action && entry[1].assoc(seqno) && \
                      entry[1].assoc(seqno)[0] == seqno
          Array(entry[1].assoc(seqno)[1][:match]).each do |options|
            cmds << "no match #{options}"
          end
        end
      end
      private :remove_match_statements

      ##
      # remove_set_statemements removes all set rules for the
      # specified routemap
      #
      # @param name [String] The routemap name.
      #
      # @param action [String] The action value.
      #
      # @param seqno [String] The seqno value.
      #
      # @param cmds [Array] Array of eos commands.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def remove_set_statements(name, action, seqno, cmds)
        raise ArgumentError, 'cmds must be an Array' unless cmds.is_a?(Array)

        entries = parse_entries(name)
        return nil unless entries
        entries.each do |entry|
          next unless entry[0] == action && entry[1].assoc(seqno) && \
                      entry[1].assoc(seqno)[0] == seqno
          Array(entry[1].assoc(seqno)[1][:set]).each do |options|
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
      # ===Commands
      #   no route-map <name> <action> <seqno>
      #
      # @param name [String] The routemap name to delete from the node.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(name, action, seqno)
        configure(["no route-map #{name} #{action} #{seqno}"])
      end

      ##
      # This method will attempt to default the routemap from the nodes
      # operational config. Since routemaps do not exist by default,
      # the default action is essentially a negation and the result will
      # be the removal of the routemap clause. If the routemap does not
      # exist then this method will not perform any changes but still
      # return True.
      #
      # ===Commands
      #   no route-map <name>
      #
      # @param name [String] The routemap name to set to default.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def default(name, action, seqno)
        configure(["default route-map #{name} #{action} #{seqno}"])
      end

      ##
      # set_match_statements will set the match values for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # ===Commands
      #   route-map <name> action <value> seqno <value> match <value>
      #
      # @param name [String] The name of the routemap to create.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @param value [Array] The routemap match rules.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_match_statements(name, action, seqno, value)
        raise ArgumentError, 'value must be an Array' unless value.is_a?(Array)

        cmds = ["route-map #{name} #{action} #{seqno}"]
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
      # ===Commands
      #   route-map <name> action <value> seqno <value> set <value>
      #
      # @param name [String] The name of the routemap to create.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @param value [Array] The routemap set rules.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_set_statements(name, action, seqno, value)
        raise ArgumentError, 'value must be an Array' unless value.is_a?(Array)

        cmds = ["route-map #{name} #{action} #{seqno}"]
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
      # ===Commands
      #   route-map <name> action <value> seqno <value> continue <value>
      #
      # @param name [String] The name of the routemap to create.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @param value [Integer] The continue value.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_continue(name, action, seqno, value)
        cmds = ["route-map #{name} #{action} #{seqno}"]
        cmds << 'no continue'
        cmds << "continue #{value}"
        configure(cmds)
      end

      ##
      # set_description will set the description for a specified routemap.
      # If the specified routemap does not exist, it will be created.
      #
      # ===Commands
      #   route-map <name> action <value> seqno <value> description <value>
      #
      # @param name [String] The name of the routemap to create.
      #
      # @param action [String] Either permit or deny.
      #
      # @param seqno [Integer] The sequence number.
      #
      # @param value [String] The description value.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_description(name, action, seqno, value)
        cmds = ["route-map #{name} #{action} #{seqno}"]
        cmds << 'no description'
        cmds << "description #{value}"
        configure(cmds)
      end
    end
  end
end
