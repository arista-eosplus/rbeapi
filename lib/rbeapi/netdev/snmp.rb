#
## Copyright (c) 2014, Arista Networks, Inc.
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

module Rbeapi
  module Netdev
    ##
    # The Netdev class is a straight port of the original PuppetX netdev
    # code that existed prior to rbeapi.  This should be considered a legacy
    # implementation that will go away as the functions get merged into
    # rbeapi.
    #
    # This class should NOT be used for any further development.
    # YE BE WARNED!
    #
    class Snmp < Rbeapi::Api::Entity
      # snmp_notification_receivers obtains a list of all the snmp
      # notification receivers and returns them as an Array of resource
      # hashes suitable for the provider's new class method.  This command
      # maps the `show snmp host` command to an array of resource hashes.
      #
      # @api public
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes.
      def snmp_notification_receivers
        cmd = 'show snmp host'
        result = node.enable(cmd)
        text = result.first[:result]['output']
        parse_snmp_hosts(text)
      end

      ##
      # parse_snmp_hosts parses the raw text from the `show snmp host`
      # command and returns an Array of resource hashes.
      #
      # @param [String] text The text of the `show snmp host` output, e.g.
      #   for three hosts:
      #
      #   ```
      #   Notification host: 127.0.0.1       udp-port: 162   type: trap
      #   user: public                       security model: v3 noauth
      #
      #   Notification host: 127.0.0.1       udp-port: 162   type: trap
      #   user: smtpuser                     security model: v3 auth
      #
      #   Notification host: 127.0.0.2       udp-port: 162   type: trap
      #   user: private                      security model: v2c
      #
      #   Notification host: 127.0.0.3       udp-port: 162   type: trap
      #   user: public                       security model: v1
      #
      #   Notification host: 127.0.0.4       udp-port: 10162 type: inform
      #   user: private                      security model: v2c
      #
      #   Notification host: 127.0.0.4       udp-port: 162   type: trap
      #   user: priv@te                      security model: v1
      #
      #   Notification host: 127.0.0.4       udp-port: 162   type: trap
      #   user: public                       security model: v1
      #
      #   Notification host: 127.0.0.4       udp-port: 20162 type: trap
      #   user: private                      security model: v1
      #
      #   ```
      #
      # @api private
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes.
      def parse_snmp_hosts(text)
        re = /host: ([^\s]+)\s+.*?port: (\d+)\s+type: (\w+)\s*user: (.*?)\s+security model: (.*?)\n/m # rubocop:disable Metrics/LineLength
        text.scan(re).map do |(host, port, type, username, auth)|
          resource_hash = { name: host, ensure: :present, port: port.to_i }
          sec_match = /^v3 (\w+)/.match(auth)
          resource_hash[:security] = sec_match[1] if sec_match
          ver_match = /^(v\d)/.match(auth) # first 2 characters
          resource_hash[:version] = ver_match[1] if ver_match
          resource_hash[:type] = /trap/.match(type) ? :traps : :informs
          resource_hash[:username] = username
          resource_hash
        end
      end
      # rubocop:enable Metrics/MethodLength

      ##
      # snmp_notification_receiver_set takes a resource hash and configures a
      # SNMP notification host on the target device.  In practice this method
      # usually creates a resource because nearly all of the properties can
      # vary and are components of a resource identifier.
      #
      # @option opts [String] :name ('127.0.0.1') The hostname or ip address
      #   of the snmp notification receiver host.
      #
      # @option opts [String] :username ('public') The SNMP username, or
      #   community, to use for authentication.
      #
      # @option opts [Fixnum] :port (162) The UDP port of the receiver.
      #
      # @option opts [Symbol] :version (:v3) The version, :v1, :v2, or :v3
      #
      # @option opts [Symbol] :type (:traps) The notification type, :traps or
      #   :informs.
      #
      # @option opts [Symbol] :security (:auth) The security mode, :auth,
      #   :noauth, or :priv
      #
      # @api public
      #
      # @return [Boolean]
      def snmp_notification_receiver_set(opts = {})
        configure snmp_notification_receiver_cmd(opts)
      end

      ##
      # snmp_notification_receiver_cmd builds a command given a resource
      # hash.
      #
      # @return [String]
      def snmp_notification_receiver_cmd(opts = {})
        host = opts[:name].split(':').first
        version = /\d+/.match(opts[:version]).to_s
        version.sub!('2', '2c')
        cmd = "snmp-server host #{host}"
        cmd << " #{opts[:type] || :traps}"
        cmd << " version #{version}"
        cmd << " #{opts[:security] || :noauth}" if version == '3'
        cmd << " #{opts[:username]}"
        cmd << " udp-port #{opts[:port]}"
        cmd
      end
      private :snmp_notification_receiver_cmd

      ##
      # snmp_notification_receiver_remove removes an snmp-server host from
      # the target device.
      #
      # @option opts [String] :name ('127.0.0.1') The hostname or ip address
      #   of the snmp notification receiver host.
      #
      # @option opts [String] :username ('public') The SNMP username, or
      #   community, to use for authentication.
      #
      # @option opts [Fixnum] :port (162) The UDP port of the receiver.
      #
      # @option opts [Symbol] :version (:v3) The version, :v1, :v2, or :v3
      #
      # @option opts [Symbol] :type (:traps) The notification type, :traps or
      #   :informs.
      #
      # @option opts [Symbol] :security (:auth) The security mode, :auth,
      #   :noauth, or :priv
      #
      # @api public
      #
      # @return [Boolean]
      def snmp_notification_receiver_remove(opts = {})
        cmd = 'no ' << snmp_notification_receiver_cmd(opts)
        configure cmd
      end

      ##
      # snmp_users retrieves all of the SNMP users  defined on the target
      # device and returns an Array of Hash objects suitable for use as a
      # resource hash to the provider's initializer method.
      #
      # @api public
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes.
      def snmp_users
        cmd = 'show snmp user'
        result = node.enable(cmd)
        text = result.first[:result]['output']
        users = parse_snmp_users(text)
        users.each do |h|
          cmd = "snmp-server user #{h[:name]} #{h[:roles]} #{h[:version]}"
          password = snmp_user_password_hash(config, cmd)[:auth]
          h[:password] = password if password
        end
      end

      ##
      # parse_snmp_users takes the text output from the `show snmp user` EAPI
      # command and parses the text into structured data suitable for use as
      # a resource has to the provider initializer method.
      #
      # ```
      #
      # User name      : jeff
      # Security model : v3
      # Engine ID      : f5717f00420008177800
      # Authentication : SHA
      # Privacy        : AES-128
      # Group          : developers
      #
      # User name      : nigel
      # Security model : v2c
      # Group          : sysops (not configured)
      #
      # User name      : nigel
      # Security model : v3
      # Engine ID      : f5717f00420008177800
      # Authentication : SHA
      # Privacy        : AES-128
      # Group          : sysops
      # ```
      #
      # @param [String] text The text to parse
      #
      # @api private
      #
      # @return [Array<Hash<Symbol,Object>>] Array of resource hashes.
      def parse_snmp_users(text)
        text.split("\n\n").map do |user_s|
          user_s.scan(/^(\w+).*?: (.*)/).each_with_object({}) do |(h, v), m|
            key = SNMP_USER_PARAM[h.downcase.intern] || h.downcase.intern
            m[key] = case key
                     when :privacy  then /AES/.match(v) ? :aes128 : :des
                     when :version  then v.sub('v2c', 'v2').intern
                     when :auth     then v.downcase.intern
                     when :roles    then v.sub(/ \(.*?\)/, '')
                     else v.downcase
                     end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # Map SNMP headings from `show snmp user` to snmp_user parameter names
      SNMP_USER_PARAM = {
        user: :name,
        engine: :engine_id,
        security: :version,
        authentication: :auth,
        privacy: :privacy,
        group: :roles
      }

      ##
      # snmp_user_set creates or updates an SNMP user account on the target
      # device.
      #
      # @option opts [String] :name ('johndoe') The username
      #
      # @option opts [Array] :roles (['developers']) The group, as an Array,
      #   this user is associated with.
      #
      # @option opts [Symbol] :version (:v2) The snmp version for this user
      #   account.
      #
      # @option opts [Symbol] :auth (:sha) The authentication digest method
      #
      # @option opts [Symbol] :privacy (:aes) The encryption scheme for
      #   privacy.
      #
      # @option opts [String] :password ('abc123') The password to
      #   configure for authentication and privacy.
      #
      # @api public
      #
      # @return [Hash<Symbol,Object>] Updated properties, e.g. the password
      #   hash which is idempotent.
      def snmp_user_set(opts = {})
        group = [*opts[:roles]].first
        fail ArgumentError, 'at least one role is required' unless group
        version = opts[:version].to_s.sub('v2', 'v2c')
        cmd = user_cmd = "snmp-server user #{opts[:name]} #{group} #{version}"
        if opts[:password] && version == 'v3'
          privacy = opts[:privacy].to_s.scan(/aes|des/).first
          fail ArgumentError,
               'privacy is required when managing passwords' unless privacy
          cmd += " auth #{opts[:auth] || 'sha'} #{opts[:password]} "\
            "priv #{privacy} #{opts[:password]}"
        end
        configure cmd
        hash = snmp_user_password_hash(running_config, user_cmd)
        { password: hash[:auth] }
      end
      # rubocop:enable Metrics/MethodLength

      ##
      # snmp_user_destroy removes an SNMP user from the target device
      #
      # @option opts [String] :name ('johndoe') The username
      #
      # @option opts [Array] :roles (['developers']) The group, as an Array,
      #   this user is associated with.
      #
      # @option opts [Symbol] :version (:v2) The snmp version for this user
      #   account.
      #
      # @option opts [Symbol] :auth (:sha) The authentication digest method
      #
      # @option opts [Symbol] :privacy (:aes) The encryption scheme for
      #   privacy.
      #
      # @option opts [String] :password ('abc123') The password to
      #   configure for authentication and privacy.
      #
      # @api public
      #
      # @return [Hash<Symbol,Object>] Updated properties, e.g. the password
      #   hash which is idempotent.
      #
      # @return [String]
      def snmp_user_destroy(opts = {})
        group = [*opts[:roles]].first
        version = opts[:version].to_s.sub('v2', 'v2c')
        cmd = "no snmp-server user #{opts[:name]} #{group} #{version}"
        configure cmd
        {}
      end

      ##
      # snmp_user_password obtains the password hash from the device in order
      # to provide an idempotent configuration value.
      #
      # @param [String] running_config The text of the current running
      #   configuration.
      #
      # @param [String] user_cmd The prefix of the command that identifies
      #   the user in the running-config.  e.g. ('snmp-server user jeff
      #   developers v3')
      #
      # @return [Hash<Symbol,String>] The hashes for :auth and :privacy
      def snmp_user_password_hash(running_config, user_cmd)
        regexp = /#{user_cmd} .*?auth \w+\s+(.*?)\s+priv \w+\s+(.*?)\s/
        (auth_hash, priv_hash) = running_config.scan(regexp).first
        { auth: auth_hash, privacy: priv_hash }
      end
    end
  end
end
