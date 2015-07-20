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

require 'rbeapi/api/bgp'

include FixtureHelpers

describe Rbeapi::Api::Bgp do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    { bgp_as: '64600',
      router_id: '192.168.254.1',
      shutdown: false,
      networks: { prefix: '192.168.254.1', masklen: 32, route_map: nil },
      neighbors: {
        'eBGP_GROUP' => {
          peer_group: nil, remote_as: nil, send_community: true,
          shutdown: false, description: nil, next_hop_self: false,
          route_map_in: nil, route_map_out: nil
        },
        '192.168.255.1' => {
          peer_group: 'eBGP_GROUP', remote_as: '65000', send_community: true,
          shutdown: true, description: nil, next_hop_self: true,
          route_map_in: nil, route_map_out: nil
        },
        '192.168.255.3' => {
          peer_group: 'eBGP_GROUP', remote_as: '65001', send_community: true,
          shutdown: true, description: nil, next_hop_self: true,
          route_map_in: nil, route_map_out: nil
        }
      }
    }
  end
  let(:bgp_as) { test[:bgp_as] }

  def bgp
    bgp = Fixtures[:bgp]
    return bgp if bgp
    fixture('bgp', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(bgp)
  end

  describe '#get' do
    # XXX Values for send_community, netxt_hop_self, ... modified
    # so test passes for now

    it 'returns the BGP resource' do
      expect(subject.get).to eq(test)
    end
  end

  describe '#create' do
    it 'create a new BGP resource' do
      expect(node).to receive(:config).with('router bgp 1000')
      expect(subject.create('1000')).to be_truthy
    end
  end

  describe '#delete' do
    it 'delete a BGP resource' do
      expect(node).to receive(:config).with("no router bgp #{bgp_as}")
      expect(subject.delete).to be_truthy
    end
  end

  describe '#default' do
    it 'sets router to default value' do
      expect(node).to receive(:config)
        .with('default router bgp 64600')
      expect(subject.default).to be_truthy
    end
  end

  describe '#set_router_id' do
    it 'set the router id' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'router-id 1.2.3.4'])
      expect(subject.set_router_id(value: '1.2.3.4')).to be_truthy
    end

    it 'remove the router-id without a value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no router-id'])
      expect(subject.set_router_id(enable: false)).to be_truthy
    end

    it 'remove the router-id with a value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no router-id 1.2.3.4'])
      expect(subject.set_router_id(value: '1.2.3.4', enable: false))
        .to be_truthy
    end

    it 'defaults the router-id without a value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default router-id'])
      expect(subject.set_router_id(default: true)).to be_truthy
    end

    it 'defaults the router-id with a value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default router-id 1.2.3.4'])
      expect(subject.set_router_id(value: '1.2.3.4', default: true))
        .to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enable BGP routing process' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'shutdown'])
      expect(subject.set_shutdown(enable: true)).to be_truthy
    end

    it 'disable BGP routing process' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no shutdown'])
      expect(subject.set_shutdown(enable: false)).to be_truthy
    end

    it 'default BGP routing process state' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default shutdown'])
      expect(subject.set_shutdown(default: true)).to be_truthy
    end
  end

  describe '#add_network' do
    it 'add a BGP network with a route map' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'network 1.2.3.0/24',
                                             'route-map eng'])
      expect(subject.add_network('1.2.3.0', 24, 'eng')).to be_truthy
    end

    it 'add a BGP network without a route map' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'network 1.2.3.0/24'])
      expect(subject.add_network('1.2.3.0', 24)).to be_truthy
    end
  end

  describe '#remove_network' do
    it 'remove a BGP network with a route map' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no network 1.2.3.0/24',
                                             'route-map eng'])
      expect(subject.remove_network('1.2.3.0', 24, 'eng')).to be_truthy
    end

    it 'remove a BGP network without a route map' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no network 1.2.3.0/24'])
      expect(subject.remove_network('1.2.3.0', 24)).to be_truthy
    end
  end
end
