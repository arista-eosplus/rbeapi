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
require 'rbeapi/api/bgp'

describe Rbeapi::Api::BgpNeighbors do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { peer_group: nil,
        remote_as: nil,
        send_community: false,
        shutdown: false,
        description: nil,
        next_hop_self: false,
        route_map_in: nil,
        route_map_out: nil,
        maximum_routes: nil }
    end

    before do
      node.config(['no router bgp 64600', 'router bgp 64600',
                   'neighbor eBGP_GROUP peer-group'])
    end

    it 'returns the BGP neighbor resource' do
      expect(subject.get('eBGP_GROUP')).to eq(entity)
    end
  end

  describe '#getall' do
    let(:entity) do
      {
        'eBGP_GROUP' => {
          peer_group: nil, remote_as: nil, send_community: false,
          shutdown: false, description: nil, next_hop_self: false,
          route_map_in: nil, route_map_out: nil, maximum_routes: '12000'
        },
        '192.168.255.1' => {
          peer_group: 'eBGP_GROUP', remote_as: '65000', send_community: true,
          shutdown: true, description: nil, next_hop_self: true,
          route_map_in: nil, route_map_out: nil, maximum_routes: nil
        },
        '192.168.255.3' => {
          peer_group: 'eBGP_GROUP', remote_as: '65001', send_community: true,
          shutdown: true, description: nil, next_hop_self: true,
          route_map_in: nil, route_map_out: nil, maximum_routes: nil
        }
      }
    end

    before do
      node.config(['no router bgp 64600', 'router bgp 64600',
                   'neighbor 192.168.255.1 peer-group eBGP_GROUP',
                   'neighbor 192.168.255.1 remote-as 65000',
                   'neighbor 192.168.255.3 peer-group eBGP_GROUP',
                   'neighbor 192.168.255.3 remote-as 65001'])
    end

    it 'returns all the neighbors' do
      expect(subject.getall).to eq(entity)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has three entries' do
      expect(subject.getall.size).to eq(3)
    end
  end

  describe '#create' do
    let(:before) do
      { peer_group: nil,
        remote_as: nil,
        send_community: true,
        shutdown: true,
        description: nil,
        next_hop_self: true,
        route_map_in: nil,
        route_map_out: nil,
        maximum_routes: nil }
    end

    let(:after) do
      { peer_group: nil,
        remote_as: nil,
        send_community: false,
        shutdown: true,
        description: nil,
        next_hop_self: false,
        route_map_in: nil,
        route_map_out: nil,
        maximum_routes: nil }
    end

    before { node.config(['no router bgp 64600', 'router bgp 64600']) }

    it 'create a new BGP neighbor' do
      expect(subject.get('edge')).to eq(before)
      expect(subject.create('edge')).to be_truthy

      expect(subject.get('edge')).to eq(after)
    end
  end

  describe '#delete' do
    let(:before) do
      { peer_group: nil,
        remote_as: nil,
        send_community: false,
        shutdown: true,
        description: nil,
        next_hop_self: false,
        route_map_in: nil,
        route_map_out: nil,
        maximum_routes: nil }
    end

    let(:after) do
      { peer_group: nil,
        remote_as: nil,
        send_community: true,
        shutdown: true,
        description: nil,
        next_hop_self: true,
        route_map_in: nil,
        route_map_out: nil,
        maximum_routes: nil }
    end

    it 'delete a BGP resource' do
      expect(subject.get('edge')).to eq(before)
      expect(subject.delete('edge')).to be_truthy

      expect(subject.get('edge')).to eq(after)
    end
  end

  describe '#set_peer_group' do
    before do
      node.config(['no router bgp 64600', 'router bgp 64600',
                   'neighbor eBGP_GROUP peer-group'])
    end

    it 'set the peer group' do
      expect(subject.get('192.168.255.1')[:peer_group]).to eq(nil)
      expect(subject.set_peer_group('192.168.255.1', value: 'eBGP_GROUP'))
        .to be_truthy
      expect(subject.get('192.168.255.1')[:peer_group]).to eq('eBGP_GROUP')
    end

    it 'remove the peer group value' do
      expect(subject.set_peer_group('192.168.255.1', value: 'eBGP_GROUP'))
        .to be_truthy
      expect(subject.get('192.168.255.1')[:peer_group]).to eq('eBGP_GROUP')
      expect(subject.set_peer_group('192.168.255.1', enable: false))
        .to be_truthy
      expect(subject.get('192.168.255.1')[:peer_group]).to eq(nil)
    end

    it 'defaults the peer group value' do
      expect(subject.set_peer_group('192.168.255.1', value: 'eBGP_GROUP'))
        .to be_truthy
      expect(subject.set_peer_group('192.168.255.1', default: true))
        .to be_truthy
      expect(subject.get('192.168.255.1')[:peer_group]).to eq(nil)
    end
  end

  describe '#set_remote_as' do
    it 'set the remote AS value' do
      expect(subject.get('eng')[:remote_as]).to eq(nil)
      expect(subject.set_remote_as('eng', value: '10')).to be_truthy
      expect(subject.get('eng')[:remote_as]).to eq('10')
    end

    it 'remove the remote AS value' do
      expect(subject.get('eng')[:remote_as]).to eq('10')
      expect(subject.set_remote_as('eng', enable: false))
        .to be_truthy
      expect(subject.get('eng')[:remote_as]).to eq(nil)
    end

    it 'defaults the remote AS value' do
      expect(subject.set_remote_as('eng', value: '10')).to be_truthy
      expect(subject.set_remote_as('eng', default: true))
        .to be_truthy
      expect(subject.get('eng')[:remote_as]).to eq(nil)
    end
  end

  describe '#set_shutdown' do
    it 'shutdown neighbor' do
      expect(subject.get('eng')[:shutdown]).to eq(false)
      expect(subject.set_shutdown('eng')).to be_truthy
      expect(subject.get('eng')[:shutdown]).to eq(true)
    end

    it 'negate shutdown neighbor' do
      expect(subject.get('eng')[:shutdown]).to eq(true)
      expect(subject.set_shutdown('eng', enable: false)).to be_truthy
      expect(subject.get('eng')[:shutdown]).to eq(true)
    end

    it 'default shutdown neighbor' do
      expect(subject.get('eng')[:shutdown]).to eq(true)
      expect(subject.set_shutdown('eng', default: true)).to be_truthy
      expect(subject.get('eng')[:shutdown]).to eq(false)
    end
  end

  describe '#set_send_community' do
    it 'enable neighbor send community' do
      expect(subject.get('eng')[:send_community]).to eq(false)
      expect(subject.set_send_community('eng')).to be_truthy
      expect(subject.get('eng')[:send_community]).to eq(true)
    end

    it 'negate neighbor send community' do
      expect(subject.get('eng')[:send_community]).to eq(true)
      expect(subject.set_send_community('eng', enable: false)).to be_truthy
      expect(subject.get('eng')[:send_community]).to eq(false)
    end

    it 'default neighbor send community' do
      expect(subject.set_send_community('eng')).to be_truthy
      expect(subject.get('eng')[:send_community]).to eq(true)
      expect(subject.set_send_community('eng', default: true)).to be_truthy
      expect(subject.get('eng')[:send_community]).to eq(false)
    end
  end

  describe '#set_next_hop_self' do
    it 'enable neighbor next hop self' do
      expect(subject.get('eng')[:next_hop_self]).to eq(false)
      expect(subject.set_next_hop_self('eng')).to be_truthy
      expect(subject.get('eng')[:next_hop_self]).to eq(true)
    end

    it 'negate neighbor next hop self' do
      expect(subject.get('eng')[:next_hop_self]).to eq(true)
      expect(subject.set_next_hop_self('eng', enable: false)).to be_truthy
      expect(subject.get('eng')[:next_hop_self]).to eq(false)
    end

    it 'default neighbor next hop self' do
      expect(subject.set_next_hop_self('eng')).to be_truthy
      expect(subject.get('eng')[:next_hop_self]).to eq(true)
      expect(subject.set_next_hop_self('eng', default: true)).to be_truthy
      expect(subject.get('eng')[:next_hop_self]).to eq(false)
    end
  end

  describe '#set_route_map_in' do
    it 'set route map in value' do
      expect(subject.get('eng')[:route_map_in]).to eq(nil)
      expect(subject.set_route_map_in('eng', value: 'edge')).to be_truthy
      expect(subject.get('eng')[:route_map_in]).to eq('edge')
    end

    it 'negate route map in value' do
      expect(subject.get('eng')[:route_map_in]).to eq('edge')
      expect(subject.set_route_map_in('eng', value: 'edge', enable: false))
        .to be_truthy
      expect(subject.get('eng')[:route_map_in]).to eq(nil)
    end

    it 'default route map in value' do
      expect(subject.set_route_map_in('eng', value: 'edge')).to be_truthy
      expect(subject.get('eng')[:route_map_in]).to eq('edge')
      expect(subject.set_route_map_in('eng', value: 'edge', default: true))
        .to be_truthy
      expect(subject.get('eng')[:route_map_in]).to eq(nil)
    end
  end

  describe '#set_route_map_out' do
    it 'set route map out value' do
      expect(subject.get('eng')[:route_map_out]).to eq(nil)
      expect(subject.set_route_map_out('eng', value: 'edge')).to be_truthy
      expect(subject.get('eng')[:route_map_out]).to eq('edge')
    end

    it 'negate route map out value' do
      expect(subject.get('eng')[:route_map_out]).to eq('edge')
      expect(subject.set_route_map_out('eng', value: 'edge', enable: false))
        .to be_truthy
      expect(subject.get('eng')[:route_map_out]).to eq(nil)
    end

    it 'default route map out value' do
      expect(subject.set_route_map_out('eng', value: 'edge')).to be_truthy
      expect(subject.get('eng')[:route_map_out]).to eq('edge')
      expect(subject.set_route_map_out('eng', value: 'edge', default: true))
        .to be_truthy
      expect(subject.get('eng')[:route_map_out]).to eq(nil)
    end
  end

  describe '#set_description' do
    it 'set the description value' do
      expect(subject.get('eng')[:description]).to eq(nil)
      expect(subject.set_description('eng', value: 'text')).to be_truthy
      expect(subject.get('eng')[:description]).to eq('text')
    end

    it 'negate the description value' do
      expect(subject.get('eng')[:description]).to eq('text')
      expect(subject.set_description('eng', enable: false)).to be_truthy
      expect(subject.get('eng')[:description]).to eq(nil)
    end

    it 'defaults the description value' do
      expect(subject.set_description('eng', value: 'text')).to be_truthy
      expect(subject.get('eng')[:description]).to eq('text')
      expect(subject.set_description('eng', default: true)).to be_truthy
      expect(subject.get('eng')[:description]).to eq(nil)
    end
  end

  describe '#set_maximum_routes' do
    it 'set the maximum routes value' do
      expect(subject.get('eng')[:maximum_routes]).to eq('12000')
      expect(subject.set_maximum_routes('eng', value: '10')).to be_truthy
      expect(subject.get('eng')[:maximum_routes]).to eq('0')
    end

    it 'defaults the maximum routes value' do
      expect(subject.set_maximum_routes('eng', value: '0')).to be_truthy
      expect(subject.set_maximum_routes('eng', default: true))
        .to be_truthy
      expect(subject.get('eng')[:maximum_routes]).to eq('12000')
    end
  end
end
