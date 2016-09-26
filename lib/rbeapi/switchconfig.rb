#
# Copyright (c) 2016, Arista Networks, Inc.
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

##
# Rbeapi toplevel namespace
module Rbeapi
  ##
  # Rbeapi::SwitchConfig
  module SwitchConfig
    ##
    # Section class
    #
    # A switch configuration section consists of the command line that
    # enters into the configuration mode, an array of command strings
    # that are executed in the current configuration mode, a reference
    # to the parent section, and an array of refereces to all sub-sections
    # contained within this section. A sub-section is a nested configuration
    # mode.
    #
    # Read Accessors for following class instance variables:
    #   line: <string>,
    #   parent: <Section>,
    #   cmds: array<strings>,
    #   children: array<Section>
    #
    class Section
      attr_reader :line
      attr_reader :parent
      attr_reader :cmds
      attr_reader :children

      ##
      # The Section class contains a parsed section of switch config.
      #
      # @param config [String] A string containing the switch configuration.
      #
      # @return [Section] Returns an instance of Section

      def initialize(line, parent)
        @line = line
        @parent = parent
        @cmds = []
        @children = []
      end

      ##
      # Add a child to the end of the children array.
      #
      # @param child [Section] A Section class instance.
      def add_child(child)
        @children.push(child)
      end

      ##
      # Add a cmd to the end of the cmds array if it is not already in
      # the cmd array.
      #
      # @param cmd [String] A command string that is added to the cmds array.
      def add_cmd(cmd)
        @cmds.push(cmd) unless @cmds.include?(cmd)
      end

      ##
      # Return the child that has the specified line (command mode).
      #
      # @param line [String] The mode command for this section.
      def get_child(line)
        @children.each do |child|
          return child if child.line == line
        end
        nil
      end

      ##
      # Private campare method to compare the commands between two Section
      # classes.
      #
      # @param cmds2 [Array<String>] An array of commands.
      #
      # @return [Array<String>] The array of commands in @cmds that are not
      #   in cmds2. The array is empty if @cmds equals cmds2.
      def _compare_cmds(cmds2)
        c1 = Set.new(@cmds)
        c2 = Set.new(cmds2)
        # Compare the commands and return the difference as an array of strings
        c1.difference(c2).to_a
      end
      private :_compare_cmds

      ##
      # Campare method to compare two Section classes.
      # The comparison will recurse through all the children in the Sections.
      # The parent is ignored at the top level section. Only call this
      # method if self and section2 have the same line.
      #
      # @param section2 [Section] An instance of a Section class to compare.
      #
      # @return [Section] The Section object contains the portion of self
      #   that is not in section2.
      def compare_r(section2)
        fail '@line must equal section2.line' if @line != section2.line

        # XXX Need to have a list of exceptions of mode commands that
        # support default. If all the commands have been removed from
        # that section in the new config then the old config just wants
        # to default the mode command.
        # ex: spanning-tree mst configuration
        #       instance 1 vlan  1
        # Currently generates this error:
        # '   default instance 1 vlan  1' failed: invalid command

        results = Section.new(@line, nil)

        # Compare the commands
        diff_cmds = _compare_cmds(section2.cmds)
        diff_cmds.each do |cmd|
          results.add_cmd(cmd)
        end

        # Using a depth first search to recursively descend through the
        # children doing a comparison.
        @children.each do |s1_child|
          s2_child = section2.get_child(s1_child.line)
          if s2_child
            # Sections Match based on the line. Compare the children
            # and if there are differences add them to the results.
            res = s1_child.compare_r(s2_child)
            if !res.children.empty? || !res.cmds.empty?
              results.add_child(res)
              results.add_cmd(s1_child.line)
            end
          else
            # Section 1 has child, but section 2 does not, add to results
            results.add_child(s1_child.clone)
            results.add_cmd(s1_child.line)
          end
        end

        results
      end

      ##
      # Campare a Section class to the current section.
      # The comparison will recurse through all the children in the Sections.
      # The parent is ignored at the top level section.
      #
      # @param section2 [Section] An instance of a Section class to compare.
      #
      # @return [Array<Section>] Returns an array of 2 Section objects. The
      #   first Section object contains the portion of self that is not
      #   in section2. The second Section object returned is the portion of
      #   section2 that is not in self.
      def compare(section2)
        if @line != section2.line
          fail 'XXX What if @line does not equal section2.line'
        end

        results = []
        # Compare self with section2
        results[0] = compare_r(section2)
        # Compare section2 with self
        results[1] = section2.compare_r(self)
        results
      end
    end

    ##
    # SwitchConfig class
    class SwitchConfig
      attr_accessor :name
      attr_reader :global

      ##
      # The SwitchConfig class will parse a string containing a switch
      # configuration and return an instance of a SwitchConfig. The
      # SwitchConfig contains the global section which contains
      # references to all sub-sections (children).
      #
      # {
      #   global: <Section>,
      # }
      #
      # @param config [String] A string containing the switch configuration.
      #
      # @return [Section] Returns an instance of Section
      def initialize(config)
        @indent = 3
        @multiline_cmds = ['^banner', '^\s*ssl key', '^\s*ssl certificate',
                           '^\s*protocol https certificate']
        chk_format(config)
        parse(config)
      end

      ##
      # Check format on a switch configuration string.
      #
      # Verify that the indentation is correct on the switch configuration.
      #
      # @param config [String] A string containing the switch configuration.
      #
      # @return [boolean] Returns true if format is good, otherwise raises
      #  an argument error.
      def chk_format(config)
        skip = false
        config.each_line do |line|
          skip = true if @multiline_cmds.any? { |cmd| line =~ /#{cmd}/ }
          if skip
            if line =~ /^\s*EOF$/
              skip = false
            else
              next
            end
          end
          ind = line[/\A */].size
          if ind % @indent != 0
            fail ArgumentError, 'SwitchConfig indentation must be multiple of '\
                                "#{@indent} improper indent #{ind}: #{line}"
          end
        end
        true
      end
      private :chk_format

      ##
      # Parse a switch configuration into sections.
      #
      # Parse a switch configuration and return a Config class.
      # A switch configuration consists of the global section that contains
      # a reference to all switch configuration sub-sections (children).
      # Lines starting with '!' (comments) are ignored
      #
      # @param config [String] A string containing the switch configuration.
      # rubocop:disable Metrics/MethodLength
      def parse(config)
        # Setup global section
        section = Section.new('', nil)
        @global = section

        prev_indent = 0
        prev_line = ''
        combine = false
        longline = []

        config.each_line do |line|
          if @multiline_cmds.any? { |cmd| line =~ /#{cmd}/ }
            longline = []
            combine = true
          end
          if combine
            longline << line
            if line =~ /^\s*EOF$/
              line = longline.join
              combine = false
            else
              next
            end
          end

          # Ignore comment lines and the end statement if there
          # XXX Fix parsing end
          next if line.start_with?('!') || line.start_with?('end')
          line.chomp!
          next if line.empty?
          indent_level = line[/\A */].size / @indent
          if indent_level > prev_indent
            # New section
            section = Section.new(prev_line, section)
            section.parent.add_child(section)
            prev_indent = indent_level
          elsif indent_level < prev_indent
            # XXX This has a bug if we pop more than one section
            # XXX Bug if we have 2 subsections with intervening commands
            # End of current section
            section = section.parent
            prev_indent = indent_level
          end
          # Add the line to the current section
          section.add_cmd(line)
          prev_line = line
        end
      end
      private :parse
      # rubocop:enable Metrics/MethodLength

      ##
      # Campare the current SwitchConfig class with another SwitchConfig class.
      #
      # @param switch_config [SwitchConfig] An instance of a SwitchConfig
      #   class to compare with the current instance.
      #
      # @return [Array<Sections>] Returns an array of 2 Section objects. The
      #   first Section object contains the portion of the current
      #   SwitchConfig instance that is not in the passed in switch_config. The
      #   second Section object is the portion of the passed in switch_config
      #   that is not in the current SwitchConfig instance.
      def compare(switch_config)
        @global.compare(switch_config.global)
      end
    end
  end
end
