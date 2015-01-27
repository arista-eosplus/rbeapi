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
require 'rbeapi/utils'

module Rbeapi

  module Api

    class Interfaces < Entity

      METHODS = [:create, :delete, :default]

      def initialize(node)
        super(node)
        @instances = {}
      end

      def get(name)
        get_instance(name).get(name)
      end

      def getall
        interfaces = config.scan(/(?<=^interface\s).+$/)

        interfaces.each_with_object({}) do |name, hsh|
          data = get(name)
          hsh[name] = data if data
        end
      end

      def get_instance(name)
        name = name[0,2].upcase
        case name
        when 'ET'
          cls = 'Rbeapi::Api::EthernetInterface'
        else
          cls = 'Rbeapi::Api::BaseInterface'
        end

        return @instances[name] if @instances.include?(cls)
        instance = Rbeapi::Utils.class_from_string(cls).new(@node)
        @instances[name] = instance
        instance
      end

      def method_missing(method_name, *args, &block)
        if method_name.to_s =~ /set_(.*)/ || METHODS.include?(method_name)
          instance = get_instance(args[0])
          instance.send(method_name.to_sym, *args, &block)
        end
      end

      def respond_to?(method_name, name = nil)
        return super unless name
        instance = get_instance(name)
        instance.respond_to?(method_name) || super
      end

    end

    class BaseInterface < Entity

      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = { 'name' => name, 'type' => 'generic' }
        response['shutdown'] = /\s{3}(no\sshutdown)$/ !~ config
        response['description'] = value(/(?<=\s{3}description\s)(?<value>.+)$/.match(config), '')
        response
      end

      def value(mdata, default = nil)
        return mdata.group('value') if mdata
        return default
      end
      private :value

      def create(name)
        configure("interface #{name}")
      end

      def delete(name)
        configure("no interface #{name}")
      end

      def default(name)
        configure("default interface #{name}")
      end

      def set_description(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default description'
        when false
          cmds << (value.nil? ? 'no description' : "description #{value}")
        end
        configure(cmds)
      end
    end

    class EthernetInterface < BaseInterface

      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = super(name)
        response.update({ 'name' => name, 'type' => 'ethernet' })

        response['sflow'] = /\s{3}(no\ssflow)$/ !~ config

        flowc_tx = /(?<=\s{3}flowcontrol\ssend\s)(?<value>.+)$/.match(config)
        response['flowcontrol_send'] = value(flowc_tx, 'off')

        flowc_rx = /(?<=\s{3}flowcontrol\sreceive\s)(?<value>.+)$/.match(config)
        response['flowcontrol_receive'] = value(flowc_rx, 'off')

        response
      end

      def create(name)
        raise NotImplementedError, 'creating Ethernet interfaces is '\
              'not supported'
      end

      def delete(name)
        raise NotImplementedError, 'deleting Ethernet interfaces is '\
              'not supported'
      end

      def set_sflow(name, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        cmds = ["interface #{name}"]
        case default
        when true
          cmds << 'default sflow'
        when false
          cmds << (value ? 'sflow enable' : 'no sflow enable')
        end
        configure(cmds)
      end

      def set_flowcontrol(name, direction, opts = {})
        value = opts[:value]
        default = opts.fetch(:default, false)

        commands = ["interface #{name}"]
        case default
        when true
          commands << "default flowcontrol #{direction}"
        when false
          commands << (value.nil? ? "no flowcontrol #{direction}" :
                                    "flowcontrol #{direction} #{value}")
        end
        configure(commands)
      end

      def set_flowcontrol_send(name, opts = {})
        set_flowcontrol(name, 'send', opts)
      end

      def set_flowcontrol_receive(name, opts = {})
        set_flowcontrol(name, 'receive', opts)
      end


    end
  end
end
