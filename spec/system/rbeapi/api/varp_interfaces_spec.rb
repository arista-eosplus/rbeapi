require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/varp'

describe Rbeapi::Api::VarpInterfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'no interface Vlan99', 'no interface Vlan100',
                   'default interface Vlan100', 'interface Vlan100',
                   'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98', 'exit'])
    end

    it 'returns an instance for Vlan100' do
      expect(subject.get('Vlan100')).not_to be_nil
    end

    it 'does not return an instance for vlan 101' do
      expect(subject.get('Vlan101')).to be_nil
    end
  end

  describe '#getall' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'no interface Vlan99', 'no interface Vlan100',
                   'default interface Vlan100', 'interface Vlan100',
                   'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98', 'exit'])
    end

    it 'returns a collection that includes Vlan100' do
      expect(subject.getall).to include('Vlan100')
    end

    it 'returns a collection as a Hash' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#set_addresses' do
    before do
      node.config(['ip virtual-router mac-address aabb.ccdd.eeff',
                   'no interface Vlan99', 'no interface Vlan100',
                   'default interface Vlan100', 'interface Vlan100',
                   'ip address 99.99.99.99/24', 'exit'])
    end

    it 'adds new address to the list of addresses' do
      expect(subject.get('Vlan100')[:addresses]).not_to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')[:addresses]).to include('99.99.99.98')
    end

    it 'removes address from the list of addresses' do
      node.config(['interface vlan 100', 'ip address 99.99.99.99/24',
                   'ip virtual-router address 99.99.99.98'])
      expect(subject.get('Vlan100')[:addresses]).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.97']))
        .to be_truthy
      expect(subject.get('Vlan100')[:addresses]).not_to include('99.99.99.98')
    end

    it 'negate the list of addresses' do
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')[:addresses]).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', enable: false)).to be_truthy
      expect(subject.get('Vlan100')[:addresses]).to be_empty
    end

    it 'default the list of addresses' do
      expect(subject.set_addresses('Vlan100', value: ['99.99.99.98']))
        .to be_truthy
      expect(subject.get('Vlan100')[:addresses]).to include('99.99.99.98')
      expect(subject.set_addresses('Vlan100', default: true)).to be_truthy
      expect(subject.get('Vlan100')[:addresses]).to be_empty
    end

    it 'can not evaluate without addresses' do
      expect { subject.set_addresses('Vlan100') }.to raise_error ArgumentError
    end
  end
end
