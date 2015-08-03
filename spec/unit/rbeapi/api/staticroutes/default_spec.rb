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
require 'spec_helper'

require 'rbeapi/api/staticroutes'

include FixtureHelpers

describe Rbeapi::Api::Staticroutes do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def staticroutes
    staticroutes = Fixtures[:staticroutes]
    return staticroutes if staticroutes
    fixture('staticroutes', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(staticroutes)
  end

  describe '#getall' do
    it 'returns the staticroute collection' do
      expect(subject.getall).to include('1.2.3.4/32/Ethernet7')
      expect(subject.getall).to include('1.2.3.4/32/Null0')
      expect(subject.getall).to include('192.0.2.0/24/Ethernet7')
      expect(subject.getall).to include('192.0.3.0/24/192.0.3.1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has four entries' do
      expect(subject.getall.size).to eq(4)
    end
  end

  describe '#create' do
    context 'creates a new staticroute resoure' do
      it 'with minimum input' do
        expect(node).to receive(:config)
          .with('ip route 192.0.2.0/24 Ethernet1')
        expect(subject.create('192.0.2.0/24', 'Ethernet1')).to be_truthy
      end

      it 'with a router_ip' do
        expect(node).to receive(:config)
          .with('ip route 192.0.2.0/24 Ethernet1 192.168.1.1')
        expect(subject.create('192.0.2.0/24', 'Ethernet1',
                              router_ip: '192.168.1.1')).to be_truthy
      end

      it 'with distance (metric)' do
        expect(node).to receive(:config)
          .with('ip route 192.0.2.0/24 Ethernet1 254')
        expect(subject.create('192.0.2.0/24', 'Ethernet1', distance: 254))
          .to be_truthy
      end

      it 'with a tag' do
        expect(node).to receive(:config)
          .with('ip route 192.0.2.0/24 Ethernet1 tag 3')
        expect(subject.create('192.0.2.0/24', 'Ethernet1', tag: 3))
          .to be_truthy
      end

      it 'with a name' do
        expect(node).to receive(:config)
          .with('ip route 192.0.2.0/24 Ethernet1 name my_route')
        expect(subject.create('192.0.2.0/24', 'Ethernet1', name: 'my_route'))
          .to be_truthy
      end
    end
  end

  describe '#delete' do
    context 'deletes a staticroute resource' do
      it 'given only a destination network' do
        expect(node).to receive(:config).with('no ip route 192.0.2.0/24')
        expect(subject.delete('192.0.2.0/24')).to be_truthy
      end

      it 'given a destination and nexthop' do
        expect(node).to receive(:config)
          .with('no ip route 192.0.2.0/24 Ethernet1')
        expect(subject.delete('192.0.2.0/24', 'Ethernet1')).to be_truthy
      end
    end
  end
end
