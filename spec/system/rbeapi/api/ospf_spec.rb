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
                   'redistribute static route-map word',
                   'network 192.168.10.10/24 area 0.0.0.0'])
    end

    let(:entity) do
      { 'router_id' => '1.1.1.1',
        'areas' => { '0.0.0.0' => ['192.168.10.0/24'] },
        'redistribute' => { 'static' => { 'route_map' => 'word' } } }
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

    it ' includes interfaces' do
      expect(collection).to include('interfaces')
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
      expect(subject.get('1')['router_id']).to be_empty
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')['router_id']).to eq('1.1.1.1')
    end

    it 'negates the router id' do
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')['router_id']).to eq('1.1.1.1')
      expect(subject.set_router_id('1', enable: false)).to be_truthy
      expect(subject.get('1')['router_id']).to be_empty
    end

    it 'defaults the router id' do
      expect(subject.set_router_id('1', value: '1.1.1.1')).to be_truthy
      expect(subject.get('1')['router_id']).to eq('1.1.1.1')
      expect(subject.set_router_id('1', default: true)).to be_truthy
      expect(subject.get('1')['router_id']).to be_empty
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
      expect(subject.get('1')['areas']).to be_empty
      expect(subject.add_network('1', '192.168.10.0/24', '0.0.0.0'))
        .to be_truthy
      expect(subject.get('1')['areas']['0.0.0.0']).to include('192.168.10.0/24')
    end
  end

  describe '#remove_network' do
    before do
      node.config(['router ospf 1', 'network 192.168.10.10/24 area 0.0.0.0'])
    end

    it 'removes the network with area to the ospf process' do
      expect(subject.get('1')['areas']['0.0.0.0']).to include('192.168.10.0/24')
      expect(subject.remove_network('1', '192.168.10.0/24', '0.0.0.0'))
        .to be_truthy
      expect(subject.get('1')['areas']).to be_empty
    end
  end

  describe '#set_redistribute' do
    before { node.config(['no router ospf 1', 'router ospf 1']) }

    it 'configures redistribution of static routes' do
      expect(subject.get('1')['redistribute']).not_to include('static')
      expect(subject.set_redistribute('1', 'static')).to be_truthy
      expect(subject.get('1')['redistribute']).to include('static')
    end
  end
end
