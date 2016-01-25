#
# Copyright (c) 2015, Arista Networks, Inc.
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
    # The Users class provides configuration of local user resources for
    # an EOS node.
    class Users < Entity
      def initialize(node)
        super(node)
        # The regex used here parses the running configuration to find all
        # username entries. There is extra logic in the regular expression
        # to store the username as 'user' and then creates a back reference
        # to find a following configuration line that might contain the
        # users sshkey.
        @users_re = Regexp.new(/^username\s+(?<user>[^\s]+)\s+
                                privilege\s+(?<priv>\d+)
                                (\s+role\s+(?<role>\S+))?
                                (?:\s+(?<nopassword>(nopassword)))?
                                (\s+secret\s+(?<encryption>0|5|7|sha512)\s+
                                (?<secret>\S+))?.*$\n
                                (username\s+\k<user>\s+
                                 sshkey\s+(?<sshkey>.*)$)?/x)

        @encryption_map = { 'cleartext' => '0',
                            'md5' => '5',
                            'sha512' => 'sha512' }
      end

      ##
      # get returns the local user configuration.
      #
      # @example
      #   {
      #     name: <string>,
      #     privilege: <integer>,
      #     role: <string>,
      #     nopassword: <boolean>,
      #     encryption: <'cleartext', 'md5', 'sha512'>
      #     secret: <string>,
      #     sshkey: <string>
      #   }
      #
      # @param name [String] The user name to return a resource for from the
      #   nodes configuration
      #
      # @return [nil, Hash<Symbol, Object>] Returns the user resource as a
      #   Hash. If the specified user name is not found in the nodes current
      #   configuration a nil object is returned.
      def get(name)
        # The regex used here parses the running configuration to find one
        # username entry.
        user_re = Regexp.new(/^username\s+(?<user>#{name})\s+
                              privilege\s+(?<priv>\d+)
                              (\s+role\s+(?<role>\S+))?
                              (?:\s+(?<nopassword>(nopassword)))?
                              (\s+secret\s+(?<encryption>0|5|7|sha512)\s+
                              (?<secret>\S+))?.*$\n
                              (username\s+#{name}\s+
                               sshkey\s+(?<sshkey>.*)$)?/x)
        user = config.scan(user_re)
        return nil unless user && user[0]
        parse_user_entry(user[0])
      end

      ##
      # getall returns a collection of user resource hashes from the nodes
      # running configuration. The user resource collection hash is keyed
      # by the unique user name.
      #
      # @example
      #   [
      #     <username>: {
      #       name: <string>,
      #       privilege: <integer>,
      #       role: <string>,
      #       nopassword: <boolean>,
      #       encryption: <'cleartext', 'md5', 'sha512'>
      #       secret: <string>,
      #       sshkey: <string>
      #     },
      #     <username>: {
      #       name: <string>,
      #       privilege: <integer>,
      #       role: <string>,
      #       nopassword: <boolean>,
      #       encryption: <'cleartext', 'md5', 'sha512'>
      #       secret: <string>,
      #       sshkey: <string>
      #     },
      #     ...
      #   ]
      #
      # @return [Hash<Symbol, Object>] Returns a hash that represents the
      #   entire user collection from the nodes running configuration.  If
      #   there are no user names configured, this method will return an empty
      #    hash.
      def getall
        entries = config.scan(@users_re)
        response = {}
        entries.each do |user|
          response[user[0]] = parse_user_entry(user)
        end
        response
      end

      ##
      # parse_user_entry maps the tokens find to the hash entries.
      #
      # @api private
      #
      # @param user [Array] An array of values returned from the regular
      #   expression scan of the nodes configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_user_entry(user)
        hsh = {}
        hsh[:name] = user[0]
        hsh[:privilege] = user[1].to_i
        hsh[:role] = user[2]
        hsh[:nopassword] = user[3] ? true : false
        # Map the encryption value if set, if there is no mapping then
        # just return the value.
        if user[4]
          @encryption_map.each do |key, value|
            if value == user[4]
              user[4] = key
              break
            end
          end
        end
        hsh[:encryption] = user[4]
        hsh[:secret] = user[5]
        hsh[:sshkey] = user[6]
        hsh
      end
      private :parse_user_entry

      ##
      # create will create a new user name resource in the nodes current
      # configuration with the specified user name. Creating users require
      # either a secret (password) or the nopassword keyword to be specified.
      # Optional parameters can be passed in to initialize user name specific
      # settings.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   username <name> nopassword privilege <value> role <value>
      #   username <name> secret [0,5,sha512] <secret> ...
      #
      # @param name [String] The name of the user to create.
      #
      # @param opts [hash] Optional keyword arguments.
      #
      # @option opts nopassword [Boolean] Configures the user to be able to
      #   authenticate without a password challenge.
      #
      # @option opts secret [String] The secret (password) to assign to this
      #   user.
      #
      # @option opts encryption [String] Specifies how the secret is encoded.
      #   Valid values are "cleartext", "md5", "sha512".  The default is
      #   "cleartext".
      #
      # @option opts privilege [String] The privilege value to assign to
      #   the user.
      #
      # @option opts role [String] The role value to assign to the user.
      #
      # @option opts sshkey [String] The sshkey value to assign to the user.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def create(name, opts = {})
        cmd = "username #{name}"
        cmd << " privilege #{opts[:privilege]}" if opts[:privilege]
        cmd << " role #{opts[:role]}" if opts[:role]
        if opts[:nopassword] == :true
          cmd << ' nopassword'
        else
          # Map the encryption value if set, if there is no mapping then
          # just return the value.
          enc = opts.fetch(:encryption, 'cleartext')
          unless @encryption_map[enc]
            fail ArgumentError, "invalid encryption value: #{enc}"
          end
          enc = @encryption_map[enc]

          unless opts[:secret]
            fail ArgumentError,
                 'secret must be specified if nopassword is false'
          end
          cmd << " secret #{enc} #{opts[:secret]}"
        end
        cmds = [cmd]
        cmds << "username #{name} sshkey #{opts[:sshkey]}" if opts[:sshkey]
        configure(cmds)
      end

      ##
      # delete will delete an existing user name  from the nodes current
      # running configuration. If the delete method is called and the user
      # name does not exist, this method will succeed.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   no username <name>
      #
      # @param name [String] The user name to delete from the node.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def delete(name)
        configure("no username #{name}")
      end

      ##
      # default will configure the user name using the default keyword. This
      # command has the same effect as deleting the user name from the nodes
      # running configuration.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   default username <name>
      #
      # @param name [String] The user name to default in the nodes
      #   configuration.
      #
      # @return [Boolean] Returns true if the command complete successfully.
      def default(name)
        configure("default username #{name}")
      end

      ##
      # set_privilege configures the user privilege value for the specified user
      # name in the nodes running configuration. If enable is false in the
      # opts keyword Hash then the name value is negated using the no
      # keyword. If the default keyword is set to true, then the privilege value
      # is defaulted using the default keyword. The default keyword takes
      # precedence over the enable keyword
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   username <name> privilege <value>
      #   no username <name> privilege <value>
      #   default username <name> privilege <value>
      #
      # @param name [String] The user name to default in the nodes
      #   configuration.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] The privilege value to assign to the user.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the user privilege value
      #   using the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_privilege(name, opts = {})
        configure(command_builder("username #{name} privilege", opts))
      end

      ##
      # set_role configures the user role value for the specified user
      # name in the nodes running configuration. If enable is false in the
      # opts keyword Hash then the name value is negated using the no
      # keyword. If the default keyword is set to true, then the role value
      # is defaulted using the default keyword. The default keyword takes
      # precedence over the enable keyword
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   username <name> role <value>
      #   no username <name> role <value>
      #   default username <name> role <value>
      #
      # @param name [String] The user name to default in the nodes
      #   configuration.
      #
      # @param opts [Hash] Optional keyword arguments.
      #
      # @option opts value [String] The role value to assign to the user.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the user role value
      #   using the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_role(name, opts = {})
        configure(command_builder("username #{name} role", opts))
      end

      ##
      # set_sshkey configures the user sshkey value for the specified user
      # name in the nodes running configuration. If enable is false in the
      # opts keyword Hash then the name value is negated using the no
      # keyword. If the default keyword is set to true, then the sshkey value
      # is defaulted using the default keyword. The default keyword takes
      # precedence over the enable keyword.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   username <name> sshkey <value>
      #   no username <name> sshkey <value>
      #   default username <name> sshkey <value>
      #
      # @param name [String] The user name to default in the nodes
      #   configuration.
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts value [String] The sshkey value to assign to the user
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the user sshkey value
      #   using the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_sshkey(name, opts = {})
        configure(command_builder("username #{name} sshkey", opts))
      end
    end
  end
end
