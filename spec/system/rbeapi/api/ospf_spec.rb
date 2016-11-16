require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/ospf'

describe Rbeapi::Api::Ospf do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('dut') }

  describe '#get' do
    before do
      node.config(['no router ospf 1',
                   'router ospf 1',
                   'router-id 1.1.1.1',
                   'max-lsa 12000',
                   'maximum-paths 16',
                   'passive-interface default',
                   'no passive-interface Ethernet1',
                   'no passive-interface Ethernet2',
                   'redistribute static route-map word',
                   'network 192.168.10.10/24 area 0.0.0.0',
                   'network 192.168.11.10/24 area 0.0.0.0'])
    end

    let(:entity) do
      { router_id: '1.1.1.1',
        max_lsa: 12_000,
        maximum_paths: 16,
        passive_interface_default: true,
        active_interfaces: %w(Ethernet1 Ethernet2),
        passive_interfaces: [],
        areas: { '0.0.0.0' => ['192.168.10.0/24', '192.168.11.0/24'] },
        redistribute: { 'static' => { route_map: 'word' } } }
    end

    it 'returns an ospf resource instance' do
      expect(subject.get('1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    let(:collection) { subject.getall }

    it 'includes ospf process id 1' do
      expect(collection).to include('1')
    end

    it 'includes interfaces' do
      expect(collection).to include(:interfaces)
    end

    it 'is a kind of hash' do
      expect(collection).to be_a_kind_of(Hash)
    end
  end

  describe '#interfaces' do
    it 'is a kind of StpInterfaces' do
      expect(subject.interfaces).to be_a_kind_of(Rbeapi::Api::OspfInterfaces)
    end
  end

  describe '#set_router_id' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures the ospf router id to 1.1.1.1' do
      expect(subject.get('1')[:router_id]).to be_empty
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')[:router_id]).to eq('1.1.1.1')
    end

    it 'negates the router id' do
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')[:router_id]).to eq('1.1.1.1')
      expect(subject.set_router_id('1', enable: false)).to be_truthy
      expect(subject.get('1')[:router_id]).to be_empty
    end

    it 'defaults the router id' do
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')[:router_id]).to eq('1.1.1.1')
      expect(subject.set_router_id('1', default: true)).to be_truthy
      expect(subject.get('1')[:router_id]).to be_empty
    end
  end

  describe '#set_max_lsa' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures the ospf max-lsa to 24000' do
      expect(subject.get('1')[:max_lsa]).to eq(12_000)
      expect(subject.set_max_lsa('1', value: 24_000)).to be_truthy
      expect(subject.get('1')[:max_lsa]).to eq(24_000)
    end

    it 'negates the max-lsa' do
      expect(subject.set_max_lsa('1', value: 24_000)).to be_truthy
      expect(subject.get('1')[:max_lsa]).to eq(24_000)
      expect(subject.set_max_lsa('1', enable: false)).to be_truthy
      expect(subject.get('1')[:max_lsa]).to eq(12_000)
    end

    it 'defaults the max-lsa' do
      expect(subject.set_max_lsa('1', value: 24_000)).to be_truthy
      expect(subject.get('1')[:max_lsa]).to eq(24_000)
      expect(subject.set_max_lsa('1', default: true)).to be_truthy
      expect(subject.get('1')[:max_lsa]).to eq(12_000)
    end
  end

  describe '#set_maximum_paths' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures the ospf maximum-paths to 16' do
      expect(subject.get('1')[:maximum_paths]).to eq(128)
      expect(subject.set_maximum_paths('1', value: 16)).to be_truthy
      expect(subject.get('1')[:maximum_paths]).to eq(16)
    end

    it 'negates the maximum-paths' do
      expect(subject.set_maximum_paths('1', value: 16)).to be_truthy
      expect(subject.get('1')[:maximum_paths]).to eq(16)
      expect(subject.set_maximum_paths('1', enable: false)).to be_truthy
      expect(subject.get('1')[:maximum_paths]).to eq(128)
    end

    it 'defaults the maximum-paths' do
      expect(subject.set_maximum_paths('1', value: 16)).to be_truthy
      expect(subject.get('1')[:maximum_paths]).to eq(16)
      expect(subject.set_maximum_paths('1', default: true)).to be_truthy
      expect(subject.get('1')[:maximum_paths]).to eq(128)
    end
  end

  describe '#passive_interface_default' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures the passive-interface default' do
      expect(subject.get('1')[:passive_interface_default]).to eq(false)
      expect(subject.set_passive_interface_default('1', value: true))
        .to be_truthy
      expect(subject.get('1')[:passive_interface_default]).to eq(true)
    end

    it 'negates the passive-interface default' do
      expect(subject.set_passive_interface_default('1', value: true))
        .to be_truthy
      expect(subject.get('1')[:passive_interface_default]).to eq(true)
      expect(subject.set_passive_interface_default('1', enable: false))
        .to be_truthy
      expect(subject.get('1')[:passive_interface_default]).to eq(false)
    end

    it 'defaults the passive-interface default' do
      expect(subject.set_passive_interface_default('1', value: true))
        .to be_truthy
      expect(subject.get('1')[:passive_interface_default]).to eq(true)
      expect(subject.set_passive_interface_default('1', default: true))
        .to be_truthy
      expect(subject.get('1')[:passive_interface_default]).to eq(false)
    end
  end

  describe '#set_active_interfaces' do
    before do
      node.config(['no router ospf 1', 'router ospf 1',
                   'passive-interface default'])
    end

    it 'configures the ospf no passive-interface Ethernet1, 2, 3' do
      expect(subject.get('1')[:active_interfaces]).to be_empty
      expect(subject.set_active_interfaces('1',
                                           value: %w(Ethernet1
                                                     Ethernet2
                                                     Ethernet3))).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to eq(%w(Ethernet1
                                                            Ethernet2
                                                            Ethernet3))
    end

    it 'configures the ospf no passive-interface Ethernet1, 2' do
      expect(subject.set_active_interfaces('1',
                                           value: %w(Ethernet1
                                                     Ethernet2
                                                     Ethernet3))).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to eq(%w(Ethernet1
                                                            Ethernet2
                                                            Ethernet3))
      expect(subject.set_active_interfaces('1',
                                           value: %w(Ethernet1
                                                     Ethernet2))).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to eq(%w(Ethernet1
                                                            Ethernet2))
    end

    it 'negates the no passive-interface' do
      expect(subject.set_active_interfaces('1',
                                           value: %w(Ethernet1
                                                     Ethernet2))).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to eq(%w(Ethernet1
                                                            Ethernet2))
      expect(subject.set_active_interfaces('1', enable: false)).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to be_empty
    end

    it 'defaults the no passive-interface' do
      expect(subject.set_active_interfaces('1',
                                           value: %w(Ethernet1
                                                     Ethernet2))).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to eq(%w(Ethernet1
                                                            Ethernet2))
      expect(subject.set_active_interfaces('1', default: true)).to be_truthy
      expect(subject.get('1')[:active_interfaces]).to be_empty
    end
  end

  describe '#set_passive_interfaces' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures the ospf passive-interface Ethernet1, 2, 3' do
      expect(subject.get('1')[:passive_interfaces]).to be_empty
      expect(subject.set_passive_interfaces('1',
                                            value: %w(Ethernet1
                                                      Ethernet2
                                                      Ethernet3))).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to eq(%w(Ethernet1
                                                             Ethernet2
                                                             Ethernet3))
    end

    it 'configures the ospf passive-interface Ethernet1, 2' do
      expect(subject.set_passive_interfaces('1',
                                            value: %w(Ethernet1
                                                      Ethernet2
                                                      Ethernet3))).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to eq(%w(Ethernet1
                                                             Ethernet2
                                                             Ethernet3))
      expect(subject.set_passive_interfaces('1',
                                            value: %w(Ethernet1
                                                      Ethernet2))).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to eq(%w(Ethernet1
                                                             Ethernet2))
    end

    it 'negates the passive-interface' do
      expect(subject.set_passive_interfaces('1',
                                            value: %w(Ethernet1
                                                      Ethernet2))).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to eq(%w(Ethernet1
                                                             Ethernet2))
      expect(subject.set_passive_interfaces('1', enable: false)).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to be_empty
    end

    it 'defaults the passive-interface' do
      expect(subject.set_passive_interfaces('1',
                                            value: %w(Ethernet1
                                                      Ethernet2))).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to eq(%w(Ethernet1
                                                             Ethernet2))
      expect(subject.set_passive_interfaces('1', default: true)).to be_truthy
      expect(subject.get('1')[:passive_interfaces]).to be_empty
    end
  end

  describe '#create' do
    before { node.config('no router ospf 1') }

    it 'configures router ospf with process id 1' do
      expect(subject.get('1')).to be_nil
      expect(subject.create('1')).to be_truthy
      expect(subject.get('1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config('router ospf 1') }

    it 'configures router ospf with process id 1' do
      expect(subject.get('1')).not_to be_nil
      expect(subject.delete('1')).to be_truthy
      expect(subject.get('1')).to be_nil
    end
  end

  describe '#add_network' do
    before { node.config('router ospf 1') }

    it 'adds the network with area to the ospf process' do
      expect(subject.get('1')[:areas]).to be_empty
      expect(subject.add_network('1', '192.168.10.0/24', '0.0.0.0'))
        .to be_truthy
      expect(subject.get('1')[:areas]['0.0.0.0']).to include('192.168.10.0/24')
    end
  end

  describe '#remove_network' do
    before do
      node.config(['router ospf 1', 'network 192.168.10.10/24 area 0.0.0.0'])
    end

    it 'removes the network with area to the ospf process' do
      expect(subject.get('1')[:areas]['0.0.0.0']).to include('192.168.10.0/24')
      expect(subject.remove_network('1', '192.168.10.0/24', '0.0.0.0'))
        .to be_truthy
      expect(subject.get('1')[:areas]).to be_empty
    end
  end

  describe '#set_redistribute' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures redistribution of static routes' do
      expect(subject.get('1')[:redistribute]).to be_empty
      expect(subject.set_redistribute('1', 'static')).to be_truthy
      expect(subject.get('1')[:redistribute])
        .to eq('static' => { route_map: nil })
    end

    it 'configures redistribution of static routes with routemap' do
      expect(subject.set_redistribute('1', 'static')).to be_truthy
      expect(subject.get('1')[:redistribute])
        .to eq('static' => { route_map: nil })
      expect(subject.set_redistribute('1', 'static', route_map: 'test'))
        .to be_truthy
      expect(subject.get('1')[:redistribute])
        .to eq('static' => { route_map: 'test' })
    end

    it 'negates the redistribution' do
      expect(subject.set_redistribute('1', 'static', route_map: 'test'))
        .to be_truthy
      expect(subject.get('1')[:redistribute])
        .to eq('static' => { route_map: 'test' })
      expect(subject.set_redistribute('1',
                                      'static',
                                      enable: false)).to be_truthy
      expect(subject.get('1')[:redistribute]).to be_empty
    end

    it 'defaults the redistribution' do
      expect(subject.set_redistribute('1', 'connected', route_map: 'foo'))
        .to be_truthy
      expect(subject.get('1')[:redistribute])
        .to eq('connected' => { route_map: 'foo' })
      expect(subject.set_redistribute('1',
                                      'connected',
                                      default: true)).to be_truthy
      expect(subject.get('1')[:redistribute]).to be_empty
    end
  end
end
