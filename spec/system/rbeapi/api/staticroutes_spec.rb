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

require 'rbeapi/client'
require 'rbeapi/api/staticroutes'

describe Rbeapi::Api::Staticroutes do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    before do
      node.config(['no ip route 0.0.0.0/0',
                   'no ip route 1.2.3.4/32',
                   'no ip route 192.0.2.0/24',
                   'no ip route 192.0.3.0/24',
                   'ip route 1.2.3.4/32 Ethernet7 4 tag 3 name frank',
                   'ip route 1.2.3.4/32 Null0 32 tag 3 name fred',
                   'ip route 192.0.2.0/24 Ethernet7 3 tag 0 name dummy1',
                   'ip route 192.0.3.0/24 192.0.3.1 1 tag 0 name dummy2'])
    end

    it 'returns the staticroute collection' do
      expect(subject.getall).to include(destination: '1.2.3.4/32',
                                        nexthop: 'Ethernet7',
                                        distance: '4',
                                        tag: '3',
                                        name: 'frank')
      expect(subject.getall).to include(destination: '1.2.3.4/32',
                                        nexthop: 'Null0',
                                        distance: '32',
                                        tag: '3',
                                        name: 'fred')
      expect(subject.getall).to include(destination: '192.0.2.0/24',
                                        nexthop: 'Ethernet7',
                                        distance: '3',
                                        tag: '0',
                                        name: 'dummy1')
      expect(subject.getall).to include(destination: '192.0.3.0/24',
                                        nexthop: '192.0.3.1',
                                        distance: '1',
                                        tag: '0',
                                        name: 'dummy2')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Array)
    end

    it 'has four entries' do
      expect(subject.getall.size).to eq(4)
    end
  end

  describe '#create' do
    let(:resource) { subject.getall }

    before(:each) do
      node.config(['no ip route 1.2.3.4/32',
                   'no ip route 192.0.2.0/24',
                   'no ip route 192.0.3.0/24'])
    end

    context 'creates a new staticroute resoure' do
      it 'with minimum input' do
        expect(subject.getall).to eq([])
        expect(subject.create('192.0.2.0/24', 'Ethernet1')).to be_truthy
        expect(subject.getall).to eq(resource)
      end

      it 'with a router_ip' do
        node.config(['ip route 192.0.2.0/24 Ethernet1'])
        expect(subject.getall).to eq(resource)

        expect(subject.create('192.0.2.0/24', 'Ethernet1',
                              router_ip: '192.168.1.1')).to be_truthy
        expect(subject.getall).to eq(resource)
      end

      it 'with distance (metric)' do
        node.config(['ip route 192.0.2.0/24 Ethernet1'])
        expect(subject.getall).to eq(resource)

        expect(subject.create('192.0.2.0/24', 'Ethernet1', distance: 254))
          .to be_truthy
        expect(subject.getall).to include(destination: '192.0.2.0/24',
                                          nexthop: 'Ethernet1',
                                          distance: '254',
                                          tag: '0',
                                          name: nil)
      end

      it 'with a tag' do
        node.config(['ip route 192.0.2.0/24 Ethernet1'])
        expect(subject.getall).to eq(resource)

        expect(subject.create('192.0.2.0/24', 'Ethernet1', tag: 3))
          .to be_truthy
        expect(subject.getall).to include(destination: '192.0.2.0/24',
                                          nexthop: 'Ethernet1',
                                          distance: '1',
                                          tag: '3',
                                          name: nil)
      end

      it 'with a name' do
        node.config(['ip route 192.0.2.0/24 Ethernet1'])
        expect(subject.getall).to eq(resource)

        expect(subject.create('192.0.2.0/24', 'Ethernet1', name: 'my_route'))
          .to be_truthy
        expect(subject.getall).to include(destination: '192.0.2.0/24',
                                          nexthop: 'Ethernet1',
                                          distance: '1',
                                          tag: '0',
                                          name: 'my_route')
      end
    end
  end

  describe '#delete' do
    let(:resource) { subject.getall }

    before do
      node.config(['ip route 192.0.2.0/24 Ethernet1'])
    end

    context 'deletes a staticroute resource' do
      it 'given only a destination network' do
        expect(subject.getall).to eq(resource)
        expect(subject.delete('192.0.2.0/24')).to be_truthy
        expect(subject.getall).to eq([])
      end

      it 'given a destination and nexthop' do
        expect(subject.getall).to eq(resource)
        expect(subject.delete('192.0.2.0/24', 'Ethernet1')).to be_truthy
        expect(subject.getall).to eq([])
      end
    end
  end
end
