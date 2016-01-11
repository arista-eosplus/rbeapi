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
# Eos is the toplevel namespace for working with Arista EOS nodes
module Rbeapi
  ##
  # Api is module namespace for working with the EOS command API
  module Api
    ##
    # The Vrrp class manages the set of virtual routers.
    # rubocop:disable Metrics/ClassLength
    class Vrrp < Entity
      def initialize(node)
        super(node)
      end

      ##
      # get returns the all the virtual router IPs for the given layer 3
      # interface name from the nodes current configuration.
      #
      # rubocop:disable Metrics/MethodLength
      #
      # @example
      #   {
      #     1: {
      #          enable: <True|False>
      #          primary_ip: <String>
      #          priority: <Integer>
      #          description: <String>
      #          secondary_ip: [ <ip_string1>, <ip_string2> ]
      #          ip_version: <Integer>
      #          timers_advertise: <Integer>
      #          mac_addr_adv_interval: <Integer>
      #          preempt: <True|False>
      #          preempt_delay_min: <Integer>
      #          preempt_delay_reload: <Integer>
      #          delay_reload: <Integer>
      #          track: [
      #            { name: 'Ethernet3', action: 'decrement', amount: 33 },
      #            { name: 'Ethernet2', action: 'decrement', amount: 22 },
      #            { name: 'Ethernet2', action: 'shutdown' }
      #          ]
      #        }
      #   }
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @return [nil, Hash<Symbol, Object>] Returns the VRRP resource as a
      #   Hash with the virtual router ID as the key. If the interface name
      #   does not exist then a nil object is returned.
      def get(name)
        config = get_block("^interface #{name}")
        return nil unless config

        response = {}

        vrids = config.scan(/^\s+(?:no |)vrrp (\d+)/)
        vrids.uniq.each do |vrid_arr|
          # Parse the vrrp configuration for the vrid(s) in the list
          entry = {}
          vrid = vrid_arr[0]
          entry.merge!(parse_delay_reload(config, vrid))
          entry.merge!(parse_description(config, vrid))
          entry.merge!(parse_enable(config, vrid))
          entry.merge!(parse_ip_version(config, vrid))
          entry.merge!(parse_mac_addr_adv_interval(config, vrid))
          entry.merge!(parse_preempt(config, vrid))
          entry.merge!(parse_preempt_delay_min(config, vrid))
          entry.merge!(parse_preempt_delay_reload(config, vrid))
          entry.merge!(parse_primary_ip(config, vrid))
          entry.merge!(parse_priority(config, vrid))
          entry.merge!(parse_secondary_ip(config, vrid))
          entry.merge!(parse_timers_advertise(config, vrid))
          entry.merge!(parse_track(config, vrid))

          response[vrid.to_i] = entry unless entry.nil?
        end
        response
      end

      ##
      # getall returns the collection of virtual router IPs for all the
      # layer 3 interfaces from the nodes running configuration as a hash.
      # The resource collection hash is keyed by the ACL name.
      #
      # @example
      #   {
      #     'Vlan100': {
      #           1: { data },
      #         250: { data },
      #     },
      #     'Vlan200': {
      #           2: { data },
      #         250: { data },
      #     }
      # }
      #
      # @return [nil, Hash<Symbol, Object>] Returns a hash that represents
      #   the entire virtual router IPs collection for all the layer 3
      #   interfaces from the nodes running configuration.  If there are no
      #   virtual routers configured, this method will return an empty hash.
      def getall
        interfaces = config.scan(/(?<=^interface\s).+$/)
        interfaces.each_with_object({}) do |name, hsh|
          data = get(name)
          hsh[name] = data if data
        end
      end

      ##
      # parse_primary_ip scans the nodes configurations for the given
      # virtual router id and extracts the primary IP.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'primary_ip', String>] Where string is the IPv4
      #   address or nil if the value is not set.
      def parse_primary_ip(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} ip (\d+\.\d+\.\d+\.\d+)$/)
        if match.empty?
          fail 'Did not get a default value for primary_ip'
        else
          value = match[0][0]
        end
        { primary_ip: value }
      end
      private :parse_primary_ip

      ##
      # parse_priority scans the nodes configurations for the given
      # virtual router id and extracts the priority value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'priority', Integer>] The priority is between
      #   <1-255> or nil if the value is not set.
      def parse_priority(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} priority (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for priority'
        else
          value = match[0][0].to_i
        end
        { priority: value }
      end
      private :parse_priority

      ##
      # parse_timers_advertise scans the nodes configurations for the given
      # virtual router id and extracts the timers advertise value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [nil, Hash<'timers_advertise', Integer>] The timers_advertise
      #   is between <1-255> or nil if the value is not set.
      def parse_timers_advertise(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} timers advertise (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for timers advertise'
        else
          value = match[0][0].to_i
        end
        { timers_advertise: value }
      end
      private :parse_timers_advertise

      ##
      # parse_preempt scans the nodes configurations for the given
      # virtual router id and extracts the preempt value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [nil, Hash<'preempt', Integer>] The preempt is
      #   between <1-255> or nil if the value is not set.
      def parse_preempt(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} preempt$/)
        if match.empty?
          value = false
        else
          value = true
        end
        { preempt: value }
      end
      private :parse_preempt

      ##
      # parse_enable scans the nodes configurations for the given
      # virtual router id and extracts the enable value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'enable', Boolean>]
      def parse_enable(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} shutdown$/)
        if match.empty?
          value = true
        else
          value = false
        end
        { enable: value }
      end
      private :parse_enable

      ##
      # parse_secondary_ip scans the nodes configurations for the given
      # virtual router id and extracts the secondary_ip value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [nil, Hash<'secondary_ip', Array<Strings>>] Returns an empty
      #   array if the value is not set.
      def parse_secondary_ip(config, vrid)
        regex = "vrrp #{vrid} ip"
        matches = config.scan(/^\s+#{regex} (\d+\.\d+\.\d+\.\d+) secondary$/)
        response = []
        matches.each do |ip|
          response << ip[0]
        end
        { secondary_ip: response }
      end
      private :parse_secondary_ip

      ##
      # parse_description scans the nodes configurations for the given
      # virtual router id and extracts the description.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [nil, Hash<'secondary_ip', String>] Returns nil if the
      #   value is not set.
      def parse_description(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} description\s+(.*)\s*$/)
        if match.empty?
          value = nil
        else
          value = match[0][0]
        end
        { description: value }
      end
      private :parse_description

      ##
      # parse_track scans the nodes configurations for the given
      # virtual router id and extracts the track entries.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'track', Array<Hashes>] Returns an empty array if the
      #   value is not set. An example array of hashes follows:
      #   { name: 'Ethernet3', action: 'decrement', amount: 33 },
      #   { name: 'Ethernet2', action: 'decrement', amount: 22 },
      #   { name: 'Ethernet2', action: 'shutdown' }
      def parse_track(config, vrid)
        pre = "vrrp #{vrid} track "
        matches = \
          config.scan(/^\s+#{pre}(\S+) (decrement|shutdown)\s*(?:(\d+$|$))/)
        response = []
        matches.each do |name, action, amount|
          hsh = { name: name, action: action }
          hsh[:amount] = amount.to_i if action == 'decrement'
          response << hsh
        end
        { track: response }
      end
      private :parse_track

      ##
      # parse_ip_version scans the nodes configurations for the given
      # virtual router id and extracts the IP version.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'ip_version', Integer>] Returns nil if the
      #   value is not set.
      def parse_ip_version(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} ip version (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for ip version'
        else
          value = match[0][0].to_i
        end
        { ip_version: value }
      end
      private :parse_ip_version

      ##
      # parse_mac_addr_adv_interval scans the nodes configurations for the
      # given virtual router id and extracts the mac address advertisement
      # interval.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'mac_addr_adv_interval', Integer>] Returns nil if the
      #   value is not set.
      def parse_mac_addr_adv_interval(config, vrid)
        regex = "vrrp #{vrid} mac-address advertisement-interval"
        match = config.scan(/^\s+#{regex} (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for mac address ' \
               'advertisement interval'
        else
          value = match[0][0].to_i
        end
        { mac_addr_adv_interval: value }
      end
      private :parse_mac_addr_adv_interval

      ##
      # parse_preempt_delay_min scans the nodes configurations for the given
      # virtual router id and extracts the preempt delay minimum value..
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'preempt_delay_min', Integer>] Returns nil if the
      #   value is not set.
      def parse_preempt_delay_min(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} preempt delay minimum (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for preempt delay minimum'
        else
          value = match[0][0].to_i
        end
        { preempt_delay_min: value }
      end
      private :parse_preempt_delay_min

      ##
      # parse_preempt_delay_reload scans the nodes configurations for the
      # given virtual router id and extracts the preempt delay reload value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'preempt_delay_reload', Integer>] Returns nil if the
      #   value is not set.
      def parse_preempt_delay_reload(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} preempt delay reload (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for preempt delay reload'
        else
          value = match[0][0].to_i
        end
        { preempt_delay_reload: value }
      end
      private :parse_preempt_delay_reload

      ##
      # parse_delay_reload scans the nodes configurations for the given
      # virtual router id and extracts the delay reload value.
      #
      # @api private
      #
      # @param [String] :config The interface config.
      # @param [String] :vrid The virtual router id.
      #
      # @return [Hash<'delay_reload', Integer>] Returns empty hash  if the
      #   value is not set.
      def parse_delay_reload(config, vrid)
        match = config.scan(/^\s+vrrp #{vrid} delay reload (\d+)$/)
        if match.empty?
          fail 'Did not get a default value for delay reload'
        else
          value = match[0][0].to_i
        end
        { delay_reload: value }
      end
      private :parse_delay_reload

      ##
      # create will create a new virtual router ID resource for the interface
      # in the nodes current.  If the create method is called and the virtual
      # router ID already exists for the interface, this method will still
      # return true.  Create takes optional parameters, but at least one
      # parameter needs to be set or the command will fail.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     vrrp <vrid> ...
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @param [String] :vrid The virtual router id.
      #
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :enable  Enable the virtual router.
      #
      # @option :opts [String] :primary_ip  The primary IPv4 address.
      #
      # @option :opts [Integer] :priority  The priority setting for a virtual
      #   router.
      #
      # @option :opts [String] :description  Associates a text string to a
      #   virtual router.
      #
      # @option :opts [Array<String>] :secondary_ip  The secondary IPv4
      #   address to the specified virtual router.
      #
      # @option :opts [Integer] :ip_version  Configures the VRRP version for
      #   the VRRP router.
      #
      # @option :opts [Integer] :timers_advertise  The interval between
      #   successive advertisement messages that the switch sends to routers
      #   in the specified virtual router ID.
      #
      # @option :opts [Integer] :mac_addr_adv_interval  Specifies interval in
      #   seconds between advertisement packets sent to VRRP group members.
      #
      # @option :opts [Boolean] :preempt  A virtual router preempt mode
      #   setting. When preempt mode is enabled, if the switch has a higher
      #   priority it will preempt the current master virtual router. When
      #   preempt mode is disabled, the switch can become the master virtual
      #   router only when a master virtual router is not present on the
      #   subnet, regardless of priority settings.
      #
      # @option :opts [Integer] :preempt_delay_min  Interval in seconds between
      #   VRRP preempt event and takeover. Minimum delays takeover when VRRP
      #   is fully implemented.
      #
      # @option :opts [Integer] :preempt_delay_reload  Interval in seconds
      #   between VRRP preempt event and takeover. Reload delays takeover
      #   after initialization following a switch reload.
      #
      # @option :opts [Integer] :delay_reload  Delay between system reboot and
      #   VRRP initialization.
      #
      # @option :opts [Array<Hash>] :track  The track hash contains the
      #   name of an interface to track, the action to take on state-change
      #   of the tracked interface, and the amount to decrement the priority.
      #
      # @return [Boolean] returns true if the command completed successfully
      def create(name, vrid, opts = {})
        fail ArgumentError, 'create has no options set' if opts.empty?
        cmds = []
        if opts.key?(:enable)
          if opts[:enable]
            cmds << "no vrrp #{vrid} shutdown"
          else
            cmds << "vrrp #{vrid} shutdown"
          end
        end
        cmds << "vrrp #{vrid} ip #{opts[:primary_ip]}" if opts.key?(:primary_ip)
        if opts.key?(:priority)
          cmds << "vrrp #{vrid} priority #{opts[:priority]}"
        end
        if opts.key?(:description)
          cmds << "vrrp #{vrid} description #{opts[:description]}"
        end
        if opts.key?(:secondary_ip)
          cmds += build_secondary_ip_cmd(name, vrid, opts[:secondary_ip])
        end
        if opts.key?(:ip_version)
          cmds << "vrrp #{vrid} ip version #{opts[:ip_version]}"
        end
        if opts.key?(:timers_advertise)
          cmds << "vrrp #{vrid} timers advertise #{opts[:timers_advertise]}"
        end
        if opts.key?(:mac_addr_adv_interval)
          val = opts[:mac_addr_adv_interval]
          cmds << "vrrp #{vrid} mac-address advertisement-interval #{val}"
        end
        if opts.key?(:preempt)
          if opts[:preempt]
            cmds << "vrrp #{vrid} preempt"
          else
            cmds << "no vrrp #{vrid} preempt"
          end
        end
        if opts.key?(:preempt_delay_min)
          val = opts[:preempt_delay_min]
          cmds << "vrrp #{vrid} preempt delay minimum #{val}"
        end
        if opts.key?(:preempt_delay_reload)
          val = opts[:preempt_delay_reload]
          cmds << "vrrp #{vrid} preempt delay reload #{val}"
        end
        if opts.key?(:delay_reload)
          cmds << "vrrp #{vrid} delay reload #{opts[:delay_reload]}"
        end
        cmds += build_tracks_cmd(name, vrid, opts[:track]) if opts.key?(:track)
        configure_interface(name, cmds)
      end

      ##
      # delete will delete the virtual router ID on the interface from the
      # nodes current running configuration. If the delete method is called
      # and the virtual router id does not exist on the interface, this
      # method will succeed.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     no vrrp <vrid>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      #
      # @return [Boolean] returns true if the command completed successfully
      def delete(name, vrid)
        configure_interface(name, "no vrrp #{vrid}")
      end

      ##
      # default will default the virtual router ID on the interface from the
      # nodes current running configuration. This command has the same effect
      # as deleting the virtual router id from the interface in the nodes
      # running configuration. If the default method is called and the
      # virtual router id does not exist on the interface, this method will
      # succeed.
      #
      # @eos_version 4.13.7M
      #
      # @commands
      #   interface <name>
      #     default vrrp <vrid>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      #
      # @return [Boolean] returns true if the command complete successfully
      def default(name, vrid)
        configure_interface(name, "default vrrp #{vrid}")
      end

      ##
      # set_shutdown enables and disables the virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> shutdown
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :enable If enable is true then the virtual
      #   router is administratively enabled for the interface and if enable
      #   is false then the virtual router is administratively disabled
      #   for the interface. Default is true.
      #
      # @option :opts [Boolean] :default Configure shutdown using
      #   the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_shutdown(name, vrid, opts = {})
        fail 'set_shutdown has the value option set' if opts[:value]
        # Shutdown semantics are opposite of enable semantics so invert enable
        enable = opts.fetch(:enable, true)
        opts.merge!(enable: !enable)
        cmd = "vrrp #{vrid} shutdown"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_primary_ip sets the primary IP address for the virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> ip <A.B.C.D>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The primary IPv4 address.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the primary IP address using
      #   the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_primary_ip(name, vrid, opts = {})
        cmd = "vrrp #{vrid} ip"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_priority sets the priority for a virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> priority <priority>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The priority value.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the priority using
      #   the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_priority(name, vrid, opts = {})
        cmd = "vrrp #{vrid} priority"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_description sets the description for a virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> description <description>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The description value.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the description using
      #   the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_description(name, vrid, opts = {})
        cmd = "vrrp #{vrid} description"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # build_secondary_ip_cmd builds the array of commands required
      # to update the secondary IP addresses. This method allows the
      # create methods to leverage the code in the setter.
      #
      # @api private
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @param [Integer] :vrid The virtual router ID.
      #
      # @param [Array<String>] :ip_addrs Array of secondary IPv4 address.
      #   An empty array will remove all secondary IPv4 addresses set for
      #   the virtual router on the specified layer 3 interface.
      #
      # @return [Array<String>] Returns the array of commands. The
      #   array could be empty.
      def build_secondary_ip_cmd(name, vrid, ip_addrs)
        ip_addrs = Set.new ip_addrs

        # Get the current secondary IP address set for the virtual router
        # A return of nil means that nothing has been configured for
        # the virtual router.
        vrrp = get(name)
        vrrp = [] if vrrp.nil?

        if vrrp.key?(vrid)
          current_addrs = Set.new vrrp[vrid][:secondary_ip]
        else
          current_addrs = Set.new []
        end

        cmds = []
        # Add commands to delete any secondary IP addresses that are
        # currently set for the virtual router but not in ip_addrs.
        current_addrs.difference(ip_addrs).each do |addr|
          cmds << "no vrrp #{vrid} ip #{addr} secondary"
        end

        # Add commands to add any secondary IP addresses that are
        # not currently set for the virtual router but are in ip_addrs.
        ip_addrs.difference(current_addrs).each do |addr|
          cmds << "vrrp #{vrid} ip #{addr} secondary"
        end
        cmds
      end
      private :build_secondary_ip_cmd

      # set_secondary_ips configures the set of secondary IP addresses
      # associated with the virtual router.  The ip_addrs value passed
      # should be an array of IP Addresses.  This method will remove
      # secondary IP addresses that are currently set for the virtual
      # router but not included in the ip_addrs array value passed in.
      # The method will then add secondary IP addresses that are not
      # currently set for the virtual router but are included in the
      # ip_addrs array value passed in.
      #
      # @commands
      #   interface <name>
      #     {no} vrrp <vrid> ip <A.B.C.D> secondary
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @param [Integer] :vrid The virtual router ID.
      #
      # @param [Array<String>] :ip_addrs Array of secondary IPv4 address.
      #   An empty array will remove all secondary IPv4 addresses set for
      #   the virtual router on the specified layer 3 interface.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_secondary_ip(name, vrid, ip_addrs)
        cmds = build_secondary_ip_cmd(name, vrid, ip_addrs)
        return true if cmds.empty?
        configure_interface(name, cmds)
      end

      ##
      # set_ip_version sets the VRRP version for a virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> ip version <version>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The VRRP version.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the VRRP version using
      #   the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_ip_version(name, vrid, opts = {})
        cmd = "vrrp #{vrid} ip version"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_timers_advertise sets the interval between successive
      # advertisement messages that the switch sends to routers in the
      # specified virtual router ID.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> timers advertise <secs>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The timer value in seconds.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the timer advertise value
      #   using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_timers_advertise(name, vrid, opts = {})
        cmd = "vrrp #{vrid} timers advertise"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_mac_addr_adv_interval sets the interval in seconds between
      # advertisement packets sent to VRRP group members for the
      # specified virtual router ID.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> mac-address advertisement-interval <secs>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The mac address advertisement interval
      #   value in seconds.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the timer advertise value
      #   using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_mac_addr_adv_interval(name, vrid, opts = {})
        cmd = "vrrp #{vrid} mac-address advertisement-interval"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_preempt sets the virtual router's preempt mode setting. When
      # preempt mode is enabled, if the switch has a higher priority it
      # will preempt the current master virtual router. When preempt mode
      # is disabled, the switch can become the master virtual router only
      # when a master virtual router is not present on the subnet,
      # regardless of priority settings.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> preempt
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [Boolean] :enable If enable is true then the virtual
      #   router preempt mode is administratively enabled for the interface
      #   and if enable is false then the virtual router preempt mode is
      #   administratively disabled for the interface. Default is true.
      #
      # @option :opts [Boolean] :default Configure the timer advertise value
      #   using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_preempt(name, vrid, opts = {})
        fail 'set_preempt has the value option set' if opts[:value]
        cmd = "vrrp #{vrid} preempt"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_preempt_delay_min sets the minimum time in seconds for the
      # virtual router to wait before taking over the active role.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> preempt delay minimum <secs>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The preempt delay minimum value.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the preempt delay minimum
      #   value using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_preempt_delay_min(name, vrid, opts = {})
        cmd = "vrrp #{vrid} preempt delay minimum"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_preempt_delay_reload sets the preemption delay after a reload
      # only. This delay period applies only to the first interface-up
      # event after the virtual router has reloaded.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> preempt delay reload <secs>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The preempt delay reload value.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the preempt delay reload
      #   value using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_preempt_delay_reload(name, vrid, opts = {})
        cmd = "vrrp #{vrid} preempt delay reload"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # set_delay_reload sets the delay between system reboot and VRRP
      # initialization for the virtual router.
      #
      # @commands
      #   interface <name>
      #     {no | default} vrrp <vrid> delay reload <secs>
      #
      # @param [String] :name The layer 3 interface name.
      # @param [Integer] :vrid The virtual router ID.
      # @param [hash] :opts Optional keyword arguments
      #
      # @option :opts [String] :value The delay reload value.
      #
      # @option :opts [Boolean] :enable If false then the command is
      #   negated. Default is true.
      #
      # @option :opts [Boolean] :default Configure the delay reload
      #   value using the default keyword.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_delay_reload(name, vrid, opts = {})
        cmd = "vrrp #{vrid} delay reload"
        configure_interface(name, command_builder(cmd, opts))
      end

      ##
      # build_tracks_cmd builds the array of commands required
      # to update the tracks. This method allows the
      # create methods to leverage the code in the setter.
      #
      # @api private
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @param [Integer] :vrid The virtual router ID.
      #
      # @param [Array<Hash>] :tracks Array of a hash of track information.
      #   Hash format: { name: 'Eth2', action: 'decrement', amount: 33 },
      #   The name and action key are required. The amount key should only
      #   be specified if the action is shutdown. The valid actions are
      #   'decrement' and 'shutdown'.  An empty array will remove all tracks
      #   set for the virtual router on the specified layer 3 interface.
      #
      # @return [Array<String>] Returns the array of commands. The
      #   array could be empty.
      def build_tracks_cmd(name, vrid, tracks)
        # Validate the track hash
        valid_keys = [:name, :action, :amount]
        # rubocop:disable Style/Next
        tracks.each do |track|
          track.keys do |key|
            unless valid_keys.include?(key)
              fail ArgumentError, 'Key: #{key} invalid in track hash'
            end
          end
          unless track.key?(:name) && track.key?(:action)
            fail ArgumentError, 'Must specify :name and :action in track hash'
          end
          unless track[:action] == 'decrement' || track[:action] == 'shutdown'
            fail ArgumentError, "Action must be 'decrement' or 'shutdown'"
          end
          if track.key?(:amount) && track[:action] != 'decrement'
            fail ArgumentError, "Action must be 'decrement' to set amount"
          end
          if track.key?(:amount)
            track[:amount] = track[:amount].to_i
            if track[:amount] < 0
              fail ArgumentError, 'Amount must be greater than zero'
            end
          end
        end

        tracks = Set.new tracks

        # Get the current tracks set for the virtual router
        # A return of nil means that nothing has been configured for
        # the virtual router.
        vrrp = get(name)
        vrrp = [] if vrrp.nil?

        if vrrp.key?(vrid)
          current_tracks = Set.new vrrp[vrid][:track]
        else
          current_tracks = Set.new []
        end

        cmds = []
        # Add commands to delete any tracks that are
        # currently set for the virtual router but not in tracks.
        current_tracks.difference(tracks).each do |tk|
          cmds << "no vrrp #{vrid} track #{tk[:name]} #{tk[:action]}"
        end

        # Add commands to add any tracks that are
        # not currently set for the virtual router but are in tracks.
        tracks.difference(current_tracks).each do |tk|
          cmd = "vrrp #{vrid} track #{tk[:name]} #{tk[:action]}"
          cmd << " #{tk[:amount]}" if tk.key?(:amount)
          cmds << cmd
        end
        cmds
      end
      private :build_tracks_cmd

      # set_tracks configures the set of track settings associated with
      # the virtual router.  The tracks value passed should be an array of
      # hashes, each hash containing a track entry.  This method will remove
      # tracks that are currently set for the virtual router but not included
      # in the tracks array value passed in.  The method will then add
      # tracks that are not currently set for the virtual router but are
      # included in the tracks array value passed in.
      #
      # @commands
      #   interface <name>
      #     {no} vrrp <vrid> track <name> <action> [<amount>]
      #
      # @param [String] :name The layer 3 interface name.
      #
      # @param [Integer] :vrid The virtual router ID.
      #
      # @param [Array<Hash>] :tracks Array of a hash of track information.
      #   Hash format: { name: 'Eth2', action: 'decrement', amount: 33 },
      #   An empty array will remove all tracks set for
      #   the virtual router on the specified layer 3 interface.
      #
      # @return [Boolean] returns true if the command complete successfully
      def set_tracks(name, vrid, tracks)
        cmds = build_tracks_cmd(name, vrid, tracks)
        return true if cmds.empty?
        configure_interface(name, cmds)
      end
    end
  end
end
