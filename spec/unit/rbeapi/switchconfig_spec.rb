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
require 'spec_helper'

require 'rbeapi/switchconfig'

include FixtureHelpers
include Rbeapi::SwitchConfig

describe Rbeapi::SwitchConfig::SwitchConfig do
  # rubocop:disable Style/TrailingWhitespace
  test_config = <<-EOS
! Config Description Comment
vlan 100
!
interface Ethernet 2
   switchport mode trunk
   switchport trunk allowed vlan 100,200
!
banner motd
This is my 
 multiline
   banner
ends here

EOF
!
EOS
  # rubocop:enable Style/TrailingWhitespace
  test_config_global = [
    'vlan 100',
    'interface Ethernet 2',
    "banner motd\nThis is my \n multiline\n   banner\nends here\n\nEOF"]
  cmds = ['   switchport mode trunk',
          '   switchport trunk allowed vlan 100,200']

  bad_indent = <<-EOS
! Vxlan without CVX
vlan 100
interface Ethernet 1
    switchport access vlan 100
!
EOS
  # rubocop:disable Style/TrailingWhitespace
  awkward_indent = <<-EOS
!
banner motd
This is my 
 multiline
   banner
that ends here

EOF
!
end
EOS
  # rubocop:enable Style/TrailingWhitespace

  subject { described_class.new(test_config) }

  # SwitchConfig class methods
  describe '#initialize' do
    it 'returns the processed configuration' do
      sc = subject.global
      # Validate the global section
      expect(sc).to be_instance_of(Section)
      expect(sc.line).to eq('')
      expect(sc.parent).to eq(nil)
      expect(sc.cmds).to eq(test_config_global)
      expect(sc.children.length).to eq(1)

      # Validate the children of global
      expect(sc.children[0].line).to eq(test_config_global[1])
      expect(sc.children[0].parent).to eq(sc)
      expect(sc.children[0].cmds).to eq(cmds)
      expect(sc.children[0].children.length).to eq(0)
    end

    it 'returns error for invalid indentation' do
      expect \
        { Rbeapi::SwitchConfig::SwitchConfig.new(bad_indent) }.to\
          raise_error ArgumentError
    end

    it 'does not return an error for tricky indentation' do
      expect \
        { Rbeapi::SwitchConfig::SwitchConfig.new(awkward_indent) }.not_to\
          raise_error
    end
  end

  describe '#compare' do
    it 'Verify compare returns array of 2 Sections' do
      expect(subject.compare(subject)).to be_instance_of(Array)
      expect(subject.compare(subject)[0]).to be_instance_of(Section)
      expect(subject.compare(subject)[1]).to be_instance_of(Section)
    end

    it 'Verify compare of same switch configs' do
      expect(subject.compare(subject)[0].line).to eq('')
      expect(subject.compare(subject)[0].cmds).to eq([])
      expect(subject.compare(subject)[0].children).to eq([])
      expect(subject.compare(subject)[1].line).to eq('')
      expect(subject.compare(subject)[1].cmds).to eq([])
      expect(subject.compare(subject)[1].children).to eq([])
    end

    it 'Verify compare of same switch configs without comment' do
      # rubocop:disable Style/TrailingWhitespace
      conf = <<-EOS
vlan 100
interface Ethernet 2
   switchport mode trunk
   switchport trunk allowed vlan 100,200
banner motd
This is my 
 multiline
   banner
ends here

EOF
EOS
      # rubocop:enable Style/TrailingWhitespace
      sw_config = Rbeapi::SwitchConfig::SwitchConfig.new(conf)
      expect(subject.compare(sw_config)[0].line).to eq('')
      expect(subject.compare(sw_config)[0].cmds).to eq([])
      expect(subject.compare(sw_config)[0].children).to eq([])
      expect(subject.compare(sw_config)[1].line).to eq('')
      expect(subject.compare(sw_config)[1].cmds).to eq([])
      expect(subject.compare(sw_config)[1].children).to eq([])
    end

    it 'Verify compare of different vlan id' do
      # rubocop:disable Style/TrailingWhitespace
      new_conf = <<-EOS
vlan 101
interface Ethernet 2
   switchport mode trunk
   switchport trunk allowed vlan 101,200
!
banner motd
This is my 
 multiline
   banner
ends here

EOF
EOS
      # rubocop:enable Style/TrailingWhitespace
      org_new_diff = <<-EOS
vlan 100
interface Ethernet 2
   switchport trunk allowed vlan 100,200
EOS
      new_org_diff = <<-EOS
vlan 101
interface Ethernet 2
   switchport trunk allowed vlan 101,200
EOS
      swc_new = Rbeapi::SwitchConfig::SwitchConfig.new(new_conf)
      swc_org_new = Rbeapi::SwitchConfig::SwitchConfig.new(org_new_diff)
      swc_new_org = Rbeapi::SwitchConfig::SwitchConfig.new(new_org_diff)
      expect(subject.compare(swc_new)[0]).to section_equal(swc_org_new.global)
      expect(subject.compare(swc_new)[1]).to section_equal(swc_new_org.global)
    end
  end

  # Section class methods
  describe 'Section Class' do
    parent = Rbeapi::SwitchConfig::Section.new('parent line', nil)
    child = Rbeapi::SwitchConfig::Section.new('child line', parent)

    describe '#initialize' do
      it 'Verify section intialization' do
        expect(child).to be_instance_of(Section)
        expect(child.line).to be_instance_of(String)
        expect(child.line).to eq('child line')
        expect(child.parent).to be_instance_of(Section)
        expect(child.parent).to eq(parent)
        expect(child.cmds).to be_instance_of(Array)
        expect(child.cmds).to be_empty
        expect(child.children).to be_instance_of(Array)
        expect(child.children).to be_empty
      end
    end

    describe '#add_child' do
      it 'Verify child added to section' do
        parent.add_child(child)
        expect(parent.children.length).to eq(1)
        expect(parent.children[0]).to eq(child)
      end
    end

    describe '#add_cmd' do
      it 'Verify command added to section' do
        parent.add_cmd('new command')
        expect(parent.cmds.length).to eq(1)
        expect(parent.cmds[0]).to eq('new command')
      end
    end

    describe '#get_child' do
      it 'Verify child returned from section' do
        parent.add_child(child)
        expect(parent.get_child('child line')).to eq(child)
      end
    end
  end
end
