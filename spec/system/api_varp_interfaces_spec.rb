require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/varp'

describe Rbeapi::Api::VarpInterfaces do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('dut') }

  describe '#get' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'default interface vlan 100', 'interface vlan 100',
                   'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98', 'exit'])
    end

    it 'returns an instance for vlan 100' do
      expect(subject.get('Vlan100')).not_to be_nil
    end

    it 'does not return an instance for vlan 101' do
      expect(subject.get('Vlan101')).to be_nil
    end
  end

  describe '#getall' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'default interface vlan 100', 'interface vlan 100',
                   'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98', 'exit'])
    end

    it 'returns a collection that includes vlan 100' do
      expect(subject.getall).to include('Vlan100')
    end

    it 'returns a collection as a Hash' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#set_addresses' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'default interface vlan 100', 'interface vlan 100',
                   'ip address 99.99.99.99/24', 'exit'])
    end

    it 'adds new address to the list of addresses' do
      expect(subject.get('Vlan100')['addresses']).not_to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')['addresses']).to include('99.99.99.98')
    end

    it 'removes address to the list of addresses' do
      node.config(['interface vlan 100', 'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98'])
      expect(subject.get('Vlan100')['addresses']).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.97']))
        .to be_truthy
      expect(subject.get('Vlan100')['addresses']).not_to include('99.99.99.98')
    end

    it 'negate the list of addresses' do
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')['addresses']).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', enable: false)).to be_truthy
      expect(subject.get('Vlan100')['addresses']).to be_empty
    end

    it 'default the list of addresses' do
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')['addresses']).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', default: true)).to be_truthy
      expect(subject.get('Vlan100')['addresses']).to be_empty
    end
  end
end
