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

describe Rbeapi::Api::BgpNeighbors do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    { bgp_as: '64600',
      router_id: '192.168.254.1',
      shutdown: false,
      networks: [
        { prefix: '192.168.254.1', masklen: 32, route_map: nil },
        { prefix: '192.168.254.2', masklen: 32, route_map: 'rmap' },
        { prefix: '192.168.254.3', masklen: 32, route_map: nil }
      ],
      neighbors: {
        'eBGP_GROUP' => {
          peer_group: nil, remote_as: nil, send_community: false,
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
    it 'returns the BGP neighbor resource' do
      expect(subject.get('eBGP_GROUP')).to eq(test[:neighbors]['eBGP_GROUP'])
    end
  end

  describe '#getall' do
    it 'returns all the neighbors' do
      expect(subject.getall).to eq(test[:neighbors])
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has three entries' do
      expect(subject.getall.size).to eq(3)
    end
  end

  describe '#create' do
    it 'create a new BGP neighbor' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor edge shutdown'])
      expect(subject.create('edge')).to be_truthy
    end
  end

  describe '#delete' do
    it 'delete a BGP resource' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor edge shutdown'])
      expect(subject.create('edge')).to be_truthy
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no neighbor edge'])
      expect(subject.delete('edge')).to be_truthy
    end
  end

  describe '#set_peer_group' do
    it 'set the peer group' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng peer-group 1.2.3.4'])
      expect(subject.set_peer_group('eng', value: '1.2.3.4')).to be_truthy
    end

    it 'remove the peer group value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no neighbor eng peer-group'])
      expect(subject.set_peer_group('eng', enable: false))
        .to be_truthy
    end

    it 'defaults the peer group value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default neighbor eng peer-group'])
      expect(subject.set_peer_group('eng', default: true))
        .to be_truthy
    end
  end

  describe '#set_remote_as' do
    it 'set the remote AS value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng remote-as 10'])
      expect(subject.set_remote_as('eng', value: '10')).to be_truthy
    end

    it 'remove the remote AS value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no neighbor eng remote-as'])
      expect(subject.set_remote_as('eng', enable: false))
        .to be_truthy
    end

    it 'defaults the remote AS value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default neighbor eng remote-as'])
      expect(subject.set_remote_as('eng', default: true))
        .to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'shutdown neighbor' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng shutdown'])
      expect(subject.set_shutdown('eng')).to be_truthy
    end

    it 'negate shutdown neighbor' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng shutdown'])
      expect(subject.set_shutdown('eng', enable: false)).to be_truthy
    end

    it 'default shutdown neighbor' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'default neighbor eng shutdown'])
      expect(subject.set_shutdown('eng', default: true)).to be_truthy
    end
  end

  describe '#set_send_community' do
    it 'enable neighbor send community' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng send-community'])
      expect(subject.set_send_community('eng')).to be_truthy
    end

    it 'negate neighbor send community' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no neighbor eng send-community'])
      expect(subject.set_send_community('eng', enable: false)).to be_truthy
    end

    it 'default neighbor send community' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'default neighbor eng send-community'])
      expect(subject.set_send_community('eng', default: true)).to be_truthy
    end
  end

  describe '#set_next_hop_self' do
    it 'enable neighbor next hop self' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng next-hop-self'])
      expect(subject.set_next_hop_self('eng')).to be_truthy
    end

    it 'negate neighbor next hop self' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'no neighbor eng next-hop-self'])
      expect(subject.set_next_hop_self('eng', enable: false)).to be_truthy
    end

    it 'default neighbor next hop self' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'default neighbor eng next-hop-self'])
      expect(subject.set_next_hop_self('eng', default: true)).to be_truthy
    end
  end

  describe '#set_route_map_in' do
    it 'set route map in value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng route-map edge in'])
      expect(subject.set_route_map_in('eng', value: 'edge')).to be_truthy
    end

    it 'negate route map in value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'no neighbor eng route-map edge in'])
      expect(subject.set_route_map_in('eng', value: 'edge', enable: false))
        .to be_truthy
    end

    it 'default route map in value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'default neighbor eng route-map edge in'])
      expect(subject.set_route_map_in('eng', value: 'edge', default: true))
        .to be_truthy
    end
  end

  describe '#set_route_map_out' do
    it 'set route map out value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng route-map edge out'])
      expect(subject.set_route_map_out('eng', value: 'edge')).to be_truthy
    end

    it 'negate route map out value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'no neighbor eng route-map edge out'])
      expect(subject.set_route_map_out('eng', value: 'edge', enable: false))
        .to be_truthy
    end

    it 'default route map out value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'default neighbor eng route-map edge out'])
      expect(subject.set_route_map_out('eng', value: 'edge', default: true))
        .to be_truthy
    end
  end

  describe '#set_description' do
    it 'set the description value' do
      expect(node).to receive(:config).with(['router bgp 64600',
                                             'neighbor eng description text'])
      expect(subject.set_description('eng', value: 'text')).to be_truthy
    end

    it 'negate the description value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'no neighbor eng description'])
      expect(subject.set_description('eng', enable: false)).to be_truthy
    end

    it 'defaults the description value' do
      expect(node).to receive(:config)
        .with(['router bgp 64600', 'default neighbor eng description'])
      expect(subject.set_description('eng', default: true)).to be_truthy
    end
  end
end
