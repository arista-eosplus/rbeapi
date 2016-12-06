#
# Copyright (c) 2014,2015, Arista Networks, Inc.
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
    # The Managementdefaults class provides a configuration instance for
    # configuring management defaults of the node.
    class Managementdefaults < Entity
      DEFAULT_SECRET_HASH = 'md5'.freeze

      ##
      # get scans the current nodes configuration and returns the values as
      # a Hash describing the current state.
      #
      # @example
      #   {
      #     secret_hash: <string>
      #   }
      #
      # @return [nil, Hash<Symbol, Object] returns the nodes current running
      #   configuration as a Hash. If management defaults are not configured
      #   on the node this method will return nil.
      def get
        config = get_block('management defaults')

        settings = {}
        settings.merge!(parse_secret_hash(config))
      end

      ##
      # parse_secret_hash scans the current nodes running configuration and
      # extracts the value of secret hash from the management defaults.
      # If the parse_secret has not been configured, then this method will
      # return DEFAULT_SECRET_HASH. The return
      # value is intended to be merged into the resource hash.
      #
      # @api private
      #
      # @param config [String] The management defaults configuration block
      #   retrieved from the nodes current running configuration.
      #
      # @return [Hash<Symbol, Object>] Returns the resource hash attribute.
      def parse_secret_hash(config)
        mdata = /(?<=\s{3}secret hash\s)(md5|sha512)$/.match(config)
        { secret_hash: mdata.nil? ? DEFAULT_SECRET_HASH : mdata[1] }
      end
      private :parse_secret_hash

      ##
      # set_secret_hash configures the management defaults secret hash value
      # in the current nodes running configuration.
      # If the default keyword is provided, the configuration is defaulted
      # using the default keyword.
      #
      # @since eos_version 4.13.7M
      #
      # ===Commands
      #   management defaults
      #     secret hash <value>
      #     no secret hash
      #     default secret hash
      #
      # @param opts [Hash] Optional keyword arguments
      #
      # @option opts value [String] The value to configure the secret hash to.
      #
      # @option opts enable [Boolean] If false then the command is
      #   negated. Default is true.
      #
      # @option opts default [Boolean] Configure the secret hash value using
      #   the default keyword.
      #
      # @return [Boolean] Returns true if the command completed successfully.
      def set_secret_hash(opts = {})
        unless ['md5', 'sha512', nil].include?(opts[:value])
          raise ArgumentError, 'secret hash must be md5 or sha512'
        end
        cmd = command_builder("secret hash #{opts[:value]}")
        cmds = ['management defaults', cmd]
        configure(cmds)
      end
    end
  end
end
