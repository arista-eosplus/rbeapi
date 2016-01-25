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
require 'rbeapi/eapilib'

##
# Rbeapi toplevel namespace.
module Rbeapi
  ##
  # Rbeapi::Api
  module Api
    ##
    # The Entity class provides a base class implementation for building
    # API modules. The Entity class is typically not instantiated directly
    # but serves as a super class with convenience methods used to
    # work with the node.
    class Entity
      attr_reader :error
      attr_reader :config
      attr_reader :node

      ##
      # Construct the node.
      #
      # @param node [Node] An instance of Rbeapi::Client::Node used to
      #   send and receive eAPI messages.
      def self.instance(node)
        new(node)
      end

      ##
      # The Entity class provides a base class implementation for building
      # API modules. The Entity class is typically not instantiated directly
      # but serves as a super class with convenience methods used to
      # work with the node.
      #
      # @param node [Node] This should be an instance of Rbeapi::Client::Node
      #   that is used to send and receive eAPI messages.
      #
      def initialize(node)
        @node = node
      end

      ##
      # Returns the running configuration from the node instance. This is
      # a convenience method to easily access the current running config
      # from an API module.
      #
      # @return [String] The current running-config from the node.
      def config
        @node.running_config
      end

      ##
      # Provides a convenience method for access the connection error (if
      # one exists) of the node's connection instance.
      #
      # @return [Rbeapi::Eapilib::CommandError] An instance of CommandError
      #   that can be used to further evaluate the root cause of an error.
      def error
        @node.connection.error
      end

      ##
      # Returns a block of configuration from the current running config
      # as a string. The argument is used to search the config and return
      # the text along with any child configuration statements.
      #
      # @param text [String] The text to be used to find the parent line
      #   in the nodes configuration.
      #
      # @return [nil, String] Returns the block of configuration based on
      #   the supplied argument. If the argument is not found in the
      #   configuration, nil is returned.
      def get_block(text)
        mdata = /^#{text}$/.match(config)
        return nil unless mdata
        block_start, line_end = mdata.offset(0)

        mdata = /^[^\s]/.match(config, line_end)
        return nil unless mdata

        _, block_end = mdata.offset(0)
        block_end -= block_start

        config[block_start, block_end]
      end

      ##
      # Method called to send configuration commands to the node. This method
      # will send the commands to the node and rescue from CommandError or
      # ConnectionError.
      #
      # @param commands [String, Array] The commands to send to the node over
      #   the API connection to configure the system.
      #
      # @return [Boolean] Returns True if the commands were successful or
      #   returns False if there was an error issuing the commands on the
      #   node.  Use error to further investigate the cause of any errors.
      def configure(commands)
        @node.config(commands)
        return true
      rescue Rbeapi::Eapilib::CommandError, Rbeapi::Eapilib::ConnectionError
        return false
      end

      ##
      # Method called to build the correct version of a command based on
      # the modifier options. If value option is set then it is appended
      # to the command. If the enable option is false then the 'no'
      # keyword is prefixed to the command. If the default value is
      # provided and set to true, then the default keyword is used. If
      # both options are provided, then default option takes precedence.
      #
      # @param cmd [String, Array] The commands to send to the node
      #   over the API connection to configure the system.
      #
      # @param opts [Hash] The options for the command.
      #
      # @option opts value [String] Optional value that is
      #   appended to the command if set.
      #
      # @option opts enable [Boolean] Prefix the command with 'no'.
      #   Default is true.
      #
      # @option opts default [Boolean] Configure the command using
      #   the default keyword. Default is false.
      #
      # @return [String] Returns built command string.
      def command_builder(cmd, opts = {})
        enable = opts.fetch(:enable, true)
        default = opts.fetch(:default, false)
        cmd << " #{opts[:value]}" if opts[:value]
        return "default #{cmd}" if default
        return "no #{cmd}" unless enable
        cmd
      end

      ##
      # configure_interface sends the commands over eAPI to the destination
      # node to configure a specific interface.
      #
      # @param name [String] The interface name to apply the configuration
      #   to. The name value must be the full interface identifier.
      #
      # @param commands [Array] The list of commands to configure the
      #   interface.
      #
      # @return [Boolean] Returns true if the commands complete successfully.
      def configure_interface(name, commands)
        commands = [*commands]
        commands.insert(0, "interface #{name}")
        configure commands
      end
    end
  end
end
