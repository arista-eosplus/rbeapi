#
## Copyright (c) 2016, Arista Networks, Inc.
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are
## met:
##
##   Redistributions of source code must retain the above copyright notice,
##   this list of conditions and the following disclaimer.
##
##   Redistributions in binary form must reproduce the above copyright
##   notice, this list of conditions and the following disclaimer in the
##   documentation and/or other materials provided with the distribution.
##
##   Neither the name of Arista Networks nor the names of its
##   contributors may be used to endorse or promote products derived from
##   this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
## A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
## BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
## BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
## OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
## IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
require 'rbeapi/api'

##
# Rbeapi toplevel namespace.
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API.
  module Api
    ##
    # The Alias class manages aliass entries on an EOS node.
    class Alias < Entity
      ##
      # get returns the current alias configuration hash extracted from the
      # nodes running configuration.
      #
      # @example
      #   {
      #     alias: array<strings>
      #   }
      #
      # @return [Hash<Symbol, Object>] Returns the alias resource as a hash
      #   object from the nodes current configuration.
      def get(name)
        # Complex regex handles the following cases:
        #  All aliases start with 'alian <name>' followed by
        #    <space><single-line command>
        #    <carriage return><multiple lines of commands>
        pattern = /^alias #{name}((?:(?= )(?:.+?)(?=\n)|\n(?:.+?)(?=\n\!)))/m
        aliases = config.scan(pattern)
        return nil unless aliases[0]
        parse_alias_entry(name, aliases[0])
      end

      ##
      # getall returns a collection of alias resource hashes from the nodes
      # running configuration. The alias resource collection hash is keyed
      # by the unique alias name.
      #
      # @example
      #   [
      #     <alias>: {
      #       command: <string>
      #     },
      #     <alias>: {
      #       command: <string>
      #     },
      #     ...
      #   ]
      #
      # @return [Hash<Symbol, Object>] Returns a hash that represents the
      #   entire alias collection from the nodes running configuration.  If
      #   there are no aliass configured, this method will return an empty
      #   hash.
      def getall
        entries = config.scan(/^alias (\w+)(.+)?/)
        entries.inspect
        response = {}
        entries.each do |aliases|
          response[aliases[0]] = get aliases[0]
        end
        response
      end

      ##
      # parse_alias_entry maps the tokens found to the hash entries.
      #
      # @api private
      #
      # @param alias [Array] An array of values returned from the regular
      #   expression scan of the aliass configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_alias_entry(name, command)
        hsh = {}
        hsh[:name] = name
        com = command[0]
        hsh[:command] = com.strip
        hsh
      end
      private :parse_alias_entry

      ##
      # create will create a alias entry in the nodes current
      # configuration with the specified address.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   alias <name> <address>
      #
      # @param name [String] The name of the alias.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts command [String] Configures the alias ip address
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(name, opts = {})
        raise ArgumentError, 'a command must be provided' unless \
            opts[:command] =~ /.+/
        command = opts.fetch(:command)
        cmd = ["alias #{name} "]
        if command =~ /\\n/
          command.split('\\n').each { |a| cmd << a }
        else
          cmd[0] << command
        end
        configure(cmd)
      end

      ##
      # delete will delete an existing alias entry from the nodes current
      # running configuration. If the delete method is called and the alias
      # entry does not exist, this method will succeed.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   no alias <name>
      #
      # @param name [String] The alias name entry to delete from the node.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(name)
        configure("no alias #{name}")
      end
    end
  end
end
