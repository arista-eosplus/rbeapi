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

describe Rbeapi::Api::Bgp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  let(:test) do
    { bgp_as: '64600',
      router_id: '192.168.254.1',
      shutdown: false,
      maximum_paths: 32,
      maximum_ecmp_paths: 32,
      networks: [
        { prefix: '192.168.254.1', masklen: 32, route_map: nil },
        { prefix: '192.168.254.2', masklen: 32, route_map: 'rmap' }
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

  describe '#get' do
    before do
      node.config(['no router bgp 64600', 'router bgp 64600',
                   'no shutdown',
                   'router-id 192.168.254.1',
                   'bgp convergence time 300',
                   'bgp convergence slow-peer time 90',
                   'no bgp confederation identifier',
                   'no update wait-for-convergence',
                   'no update wait-install',
                   'bgp log-neighbor-changes',
                   'bgp default ipv4-unicast',
                   'no bgp default ipv6-unicast',
                   'timers bgp 60 180',
                   'distance bgp 20 200 200',
                   'graceful-restart stalepath-time 300',
                   'no bgp cluster-id',
                   'bgp client-to-client reflection',
                   'graceful-restart-helper',
                   'bgp peer-mac-resolution-timeout 0',
                   'bgp enforce-first-as',
                   'no default-metric',
                   'no bgp always-compare-med',
                   'no bgp bestpath med missing-as-worst',
                   'no bgp bestpath med confed',
                   'no bgp host-routes fib direct-install',
                   'maximum-paths 32 ecmp 32',
                   'bgp listen limit 1000',
                   'no bgp aspath-cmp-include-nexthop',
                   'no bgp tie-break-on-age',
                   'no bgp tie-break-on-router-id',
                   'no bgp tie-break-on-originator-id',
                   'no bgp tie-break-on-cluster-list-length',
                   'neighbor eBGP_GROUP peer-group',
                   'no neighbor eBGP_GROUP remote-as',
                   'no neighbor eBGP_GROUP import-localpref',
                   'no neighbor eBGP_GROUP export-localpref',
                   'no neighbor eBGP_GROUP description',
                   'no neighbor eBGP_GROUP next-hop-self',
                   'no neighbor eBGP_GROUP next-hop-peer',
                   'no neighbor eBGP_GROUP allowas-in',
                   'no neighbor eBGP_GROUP send-community',
                   'no neighbor eBGP_GROUP shutdown',
                   'no neighbor eBGP_GROUP remove-private-as',
                   'no neighbor eBGP_GROUP out-delay',
                   'no neighbor eBGP_GROUP local-as',
                   'no neighbor eBGP_GROUP weight',
                   'no neighbor eBGP_GROUP transport connection-mode passive',
                   'no neighbor eBGP_GROUP update-source',
                   'no neighbor eBGP_GROUP dont-capability-negotiate',
                   'neighbor eBGP_GROUP fall-over bfd',
                   'no neighbor eBGP_GROUP local-v6-addr',
                   'neighbor eBGP_GROUP soft-reconfiguration inbound',
                   'no neighbor eBGP_GROUP ebgp-multihop',
                   'no neighbor eBGP_GROUP route-reflector-client',
                   'no neighbor eBGP_GROUP timers',
                   'no neighbor eBGP_GROUP route-map in',
                   'neighbor eBGP_GROUP graceful-restart-helper',
                   'no neighbor eBGP_GROUP route-map out',
                   'no neighbor eBGP_GROUP prefix-list in',
                   'no neighbor eBGP_GROUP prefix-list out',
                   'neighbor eBGP_GROUP password 7 6C/HkrwJ53+dsHumQf49Wg==',
                   'no neighbor eBGP_GROUP default-originate',
                   'neighbor eBGP_GROUP enforce-first-as',
                   'no neighbor eBGP_GROUP metric-out',
                   'neighbor eBGP_GROUP maximum-routes 12000',
                   'neighbor 192.168.255.1 peer-group eBGP_GROUP',
                   'neighbor 192.168.255.1 remote-as 65000',
                   'neighbor 192.168.255.3 peer-group eBGP_GROUP',
                   'neighbor 192.168.255.3 remote-as 65001',
                   'network 192.168.254.1/32',
                   'network 192.168.254.2/32 route-map rmap',
                   'bgp redistribute-internal',
                   'aggregate-address 192.168.255.0/28 summary-only',
                   'no redistribute connected',
                   'no redistribute ospf match internal',
                   'no redistribute ospf match external',
                   'no redistribute ospf match nssa-external',
                   'no redistribute ospf3 match internal',
                   'no redistribute ospf3 match external',
                   'no redistribute static',
                   'no redistribute rip',
                   'no redistribute aggregate',
                   'address-family ipv4',
                   'default neighbor eBGP_GROUP activate',
                   'no neighbor eBGP_GROUP route-map in',
                   'no neighbor eBGP_GROUP route-map out',
                   'no neighbor eBGP_GROUP default-originate',
                   'default neighbor 192.168.255.1 activate',
                   'default neighbor 192.168.255.3 activate',
                   'address-family ipv6',
                   'default neighbor eBGP_GROUP activate',
                   'no neighbor eBGP_GROUP route-map in',
                   'no neighbor eBGP_GROUP route-map out',
                   'no neighbor eBGP_GROUP prefix-list in',
                   'no neighbor eBGP_GROUP prefix-list out',
                   'no neighbor eBGP_GROUP default-originate',
                   'default neighbor 192.168.255.1 activate',
                   'default neighbor 192.168.255.3 activate'])
    end

    it 'returns the BGP resource' do
      expect(subject.get).to eq(test)
    end
  end

  describe '#create' do
    let(:response) do
      {
        bgp_as: '1000',
        router_id: nil,
        shutdown: false,
        maximum_paths: 1,
        maximum_ecmp_paths: 128,
        networks: [],
        neighbors: {}
      }
    end

    before do
      node.config(['no router bgp 64600'])
    end

    it 'create a new BGP resource' do
      expect(subject.get).to eq(nil)
      expect(subject.create('1000')).to be_truthy
      expect(subject.get).to eq(response)
    end

    it 'create with enable' do
      expect(subject.get).to eq(nil)
      expect(subject.create('1000', enable: true)).to be_truthy
      expect(subject.get).to eq(response)
    end

    it 'create with router_id' do
      expect(subject.get).to eq(nil)
      expect(subject.create('1000', router_id: '1.2.3.4')).to be_truthy
      expect(subject.get[:router_id]).to eq('1.2.3.4')
    end

    it 'create with maximum paths' do
      expect(subject.get).to eq(nil)
      expect(subject.create('1000', maximum_paths: 3)).to be_truthy
      expect(subject.get[:maximum_paths]).to eq(3)
    end

    it 'create with maximum paths and ecmp paths' do
      expect(subject.get).to eq(nil)
      expect(subject.create('1000', maximum_paths: 13,
                                    maximum_ecmp_paths: 13)).to be_truthy
      expect(subject.get[:maximum_paths]).to eq(13)
      expect(subject.get[:maximum_ecmp_paths]).to eq(13)
    end

    it 'raises ArgumentError for create with ecmp paths only' do
      expect { subject.create('1000', maximum_ecmp_paths: 13) }.to \
        raise_error ArgumentError
    end

    it 'create with all options set' do
      expect(subject.create('1000', enable: true, router_id: '1.2.3.4',
                                    maximum_paths: 13,
                                    maximum_ecmp_paths: 13)).to be_truthy
      expect(subject.get[:router_id]).to eq('1.2.3.4')
      expect(subject.get[:maximum_paths]).to eq(13)
      expect(subject.get[:maximum_ecmp_paths]).to eq(13)
    end
  end

  describe '#delete' do
    before do
      node.config(['no router bgp 1000', 'router bgp 1000'])
    end

    let(:response) do
      {
        bgp_as: '1000',
        router_id: nil,
        shutdown: false,
        maximum_paths: 1,
        maximum_ecmp_paths: 128,
        networks: [],
        neighbors: {}
      }
    end

    it 'delete a BGP resource' do
      expect(subject.get).to eq(response)
      expect(subject.delete).to be_truthy
      expect(subject.get).to eq(nil)
    end
  end

  describe '#default' do
    before do
      node.config(['no router bgp 1000', 'router bgp 1000',
                   'maximum-paths 13 ecmp 15'])
    end

    let(:before) do
      {
        bgp_as: '1000',
        router_id: nil,
        shutdown: false,
        maximum_paths: 13,
        maximum_ecmp_paths: 15,
        networks: [],
        neighbors: {}
      }
    end

    it 'sets router to default value' do
      expect(subject.get).to eq(before)
      expect(subject.default).to be_truthy
      expect(subject.get).to eq(nil)
    end
  end

  describe '#set_router_id' do
    before do
      node.config(['no router bgp 1000', 'router bgp 1000'])
    end

    it 'set the router id' do
      expect(subject.set_router_id(value: '1.2.3.4')).to be_truthy
      expect(subject.get[:router_id]).to eq('1.2.3.4')
    end

    it 'remove the router-id without a value' do
      expect(subject.set_router_id(enable: false)).to be_truthy
      expect(subject.get[:router_id]).to eq(nil)
    end

    it 'remove the router-id with a value' do
      expect(subject.set_router_id(value: '1.2.3.4', enable: false))
        .to be_truthy
      expect(subject.get[:router_id]).to eq(nil)
    end

    it 'defaults the router-id without a value' do
      expect(subject.set_router_id(value: '1.2.3.4')).to be_truthy
      expect(subject.set_router_id(default: true)).to be_truthy
      expect(subject.get[:router_id]).to eq(nil)
    end

    it 'defaults the router-id with a value' do
      expect(subject.set_router_id(value: '1.2.3.4', default: true))
        .to be_truthy
      expect(subject.get[:router_id]).to eq(nil)
    end
  end

  describe '#set_shutdown' do
    it 'enable BGP routing process' do
      expect(subject.set_shutdown(enable: true)).to be_truthy
    end

    it 'disable BGP routing process' do
      expect(subject.set_shutdown(enable: false)).to be_truthy
    end

    it 'default BGP routing process state' do
      expect(subject.set_shutdown(default: true)).to be_truthy
    end
  end

  describe '#set_maximum_paths' do
    it 'set the maximum paths and ecmp paths' do
      expect(subject.set_maximum_paths(13, 16)).to be_truthy
    end

    it 'remove the maximum paths' do
      expect(subject.set_maximum_paths(0, 0, enable: false)).to be_truthy
    end

    it 'defaults the maximum paths' do
      expect(subject.set_maximum_paths(0, 0, default: true)).to be_truthy
    end
  end

  describe '#add_network' do
    it 'add a BGP network with a route map' do
      expect(subject.add_network('1.2.3.0', 24, 'eng')).to be_truthy
    end

    it 'add a BGP network without a route map' do
      expect(subject.add_network('1.2.3.0', 24)).to be_truthy
    end
  end

  describe '#remove_network' do
    it 'remove a BGP network with a route map' do
      expect(subject.remove_network('1.2.3.0', 24, 'eng')).to be_truthy
    end

    it 'remove a BGP network without a route map' do
      expect(subject.remove_network('1.2.3.0', 24)).to be_truthy
    end
  end
end
