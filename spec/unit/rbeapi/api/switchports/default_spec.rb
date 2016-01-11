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

require 'rbeapi/api/switchports'

include FixtureHelpers

describe Rbeapi::Api::Switchports do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def switchports
    switchports = Fixtures[:switchports]
    return switchports if switchports
    fixture('switchports', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(switchports)
  end

  describe '#get' do
    let(:keys) do
      [:mode, :access_vlan, :trunk_native_vlan, :trunk_allowed_vlans,
       :trunk_groups]
    end

    context 'vlan as an integer range' do
      it 'returns the switchport resource' do
        expect(subject.get('Ethernet1')).not_to be_nil
      end

      it 'does not return a nonswitchport resource' do
        expect(subject.get('Ethernet2')).to be_nil
      end

      it 'has all required keys' do
        expect(subject.get('Ethernet1').keys).to eq(keys)
      end

      it 'returns allowed_vlans as an array' do
        expect(subject.get('Ethernet1')[:trunk_allowed_vlans])
          .to be_a_kind_of(Array)
      end
    end

    context 'vlan as an integer' do
      it 'returns the switchport resource' do
        expect(subject.get('Ethernet1')).not_to be_nil
      end
    end
  end

  describe '#getall' do
    it 'returns the switchport collection' do
      expect(subject.getall).to include('Ethernet1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'returns a hash collection' do
      expect(subject.getall.count).to eq(1)
    end
  end

  describe '#create' do
    it 'creates a new switchport resource' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no ip address', 'switchport'])
      expect(subject.create('Ethernet1')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes a switchport resource' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport'])
      expect(subject.delete('Ethernet1')).to be_truthy
    end
  end

  describe '#default' do
    it 'sets Ethernet1 to default' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport'])
      expect(subject.default('Ethernet1')).to be_truthy
    end
  end

  describe '#set_mode' do
    it 'sets mode value to access' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'switchport mode access'])
      expect(subject.set_mode('Ethernet1', value: 'access')).to be_truthy
    end

    it 'sets the mode value to trunk' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'switchport mode trunk'])
      expect(subject.set_mode('Ethernet1', value: 'trunk')).to be_truthy
    end

    it 'negate the mode value' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport mode'])
      expect(subject.set_mode('Ethernet1', enable: false)).to be_truthy
    end

    it 'default the mode value' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport mode'])
      expect(subject.set_mode('Ethernet1', default: true)).to be_truthy
    end
  end

  describe '#set_access_vlan' do
    it 'sets the access vlan value to 100' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'switchport access vlan 100'])
      expect(subject.set_access_vlan('Ethernet1', value: '100')).to be_truthy
    end

    it 'negates the access vlan value' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport access vlan'])
      expect(subject.set_access_vlan('Ethernet1', enable: false)).to be_truthy
    end

    it 'defaults the access vlan value' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport access vlan'])
      expect(subject.set_access_vlan('Ethernet1', default: true)).to be_truthy
    end
  end

  describe '#set_trunk_native_vlan' do
    it 'sets the trunk native vlan to 100' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'switchport trunk native vlan 100'])
      expect(subject.set_trunk_native_vlan('Ethernet1', value: '100'))
        .to be_truthy
    end

    it 'negates the trunk native vlan' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport trunk native vlan'])
      expect(subject.set_trunk_native_vlan('Ethernet1', enable: false))
        .to be_truthy
    end

    it 'defaults the trunk native vlan' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport trunk native vlan'])
      expect(subject.set_trunk_native_vlan('Ethernet1', default: true))
        .to be_truthy
    end
  end

  describe '#set_trunk_allowed_vlans' do
    it 'raises an ArgumentError if value is not an array' do
      expect { subject.set_trunk_allowed_vlans('Ethernet1', value: '1-100') }
        .to raise_error(ArgumentError)
    end

    it 'sets vlan 8 and 9 to the trunk allowed vlans' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'switchport trunk allowed vlan none',
               'switchport trunk allowed vlan 8,9'])
      expect(subject.set_trunk_allowed_vlans('Ethernet1', value: [8, 9]))
        .to be_truthy
    end

    it 'negate switchport trunk allowed vlan' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport trunk allowed vlan'])
      expect(subject.set_trunk_allowed_vlans('Ethernet1', enable: false))
        .to be_truthy
    end

    it 'default switchport trunk allowed vlan' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport trunk allowed vlan'])
      expect(subject.set_trunk_allowed_vlans('Ethernet1', default: true))
        .to be_truthy
    end
  end

  describe '#set_trunk_groups' do
    it 'raises an ArgumentError if value is not an array' do
      expect { subject.set_trunk_groups('Ethernet1', value: 'foo') }
        .to raise_error(ArgumentError)
    end

    it 'sets trunk group to foo bar bang' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1',  'switchport trunk group foo',
               'switchport trunk group bar', 'switchport trunk group bang'])
      expect(subject.set_trunk_groups('Ethernet1', value: %w(foo bar bang)))
        .to be_truthy
    end

    it 'negate switchport trunk group' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'no switchport trunk group'])
      expect(subject.set_trunk_groups('Ethernet1', enable: false))
        .to be_truthy
    end

    it 'default switchport trunk group' do
      expect(node).to receive(:config)
        .with(['interface Ethernet1', 'default switchport trunk group'])
      expect(subject.set_trunk_groups('Ethernet1', default: true))
        .to be_truthy
    end
  end
end
