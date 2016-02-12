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
  test_config = <<-EOS
! Test on multi-level children sections
management api http-commands
   no shutdown
   vrf cloud-mgmt
      no shutdown
EOS
  test_config_global = ['management api http-commands']
  cmds = [['   no shutdown',
           '   vrf cloud-mgmt'],
          ['      no shutdown']]

  subject { described_class.new('test', test_config) }

  # SwitchConfig class methods
  describe '#initialize' do
    it 'returns the processed configuration' do
      sc = subject.global
      # Validate the global section
      expect(sc.line).to eq('')
      expect(sc.parent).to eq(nil)
      expect(sc.cmds).to eq(test_config_global)
      expect(sc.children.length).to eq(1)

      # Validate the child of global
      expect(sc.children[0].line).to eq(test_config_global[0])
      expect(sc.children[0].parent).to eq(sc)
      expect(sc.children[0].cmds).to eq(cmds[0])
      expect(sc.children[0].children.length).to eq(1)

      # Validate the child of global
      child = sc.children[0].children
      expect(child[0].line).to eq(cmds[0][1])
      expect(child[0].parent).to eq(sc.children[0])
      expect(child[0].cmds).to eq(cmds[1])
      expect(child[0].children.length).to eq(0)
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

    it 'Verify compare of shutdown management vrf' do
      new_conf = <<-EOS
management api http-commands
   no shutdown
   vrf cloud-mgmt
      shutdown
EOS
      org_new_diff = <<-EOS
management api http-commands
   vrf cloud-mgmt
      no shutdown
EOS
      new_org_diff = <<-EOS
management api http-commands
   vrf cloud-mgmt
      shutdown
EOS
      swc_new = Rbeapi::SwitchConfig::SwitchConfig.new('', new_conf)
      swc_org_new = Rbeapi::SwitchConfig::SwitchConfig.new('', org_new_diff)
      swc_new_org = Rbeapi::SwitchConfig::SwitchConfig.new('', new_org_diff)
      expect(subject.compare(swc_new)[0]).to section_equal(swc_org_new.global)
      expect(subject.compare(swc_new)[1]).to section_equal(swc_new_org.global)
    end
  end
end
