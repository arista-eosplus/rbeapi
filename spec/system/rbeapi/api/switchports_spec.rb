require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/switchports'

describe Rbeapi::Api::Switchports do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('veos02') }

  describe '#get' do

    let(:entity) do
      { mode: 'access', access_vlan: '1', trunk_native_vlan: '1',
        trunk_allowed_vlans: '1-4094' }
    end

    before { node.config('default interface Ethernet1') }

    it 'returns the switchport resource' do
      expect(subject.get('Ethernet1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config('default interface Ethernet1-7') }

    it 'returns the switchport collection' do
      expect(subject.getall).to include('Ethernet1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
 end

  describe '#create' do
    before { node.config(['interface Ethernet1', 'no switchport']) }

    it 'creates a new switchport resource' do
      expect(subject.get('Ethernet1')).to be_nil
      expect(subject.create('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Ethernet1', 'switchport']) }

    it 'deletes a switchport resource' do
      expect(subject.get('Ethernet1')).not_to be_nil
      expect(subject.delete('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Ethernet1', 'no switchport']) }

    it 'sets Ethernet1 to default' do
      expect(subject.get('Ethernet1')).to be_nil
      expect(subject.default('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).not_to be_nil
    end
  end

  describe '#set_mode' do
    it 'sets mode value to access' do
      node.config(['interface Ethernet1', 'switchport mode trunk'])
      expect(subject.get('Ethernet1')[:mode]).to eq('trunk')
      expect(subject.set_mode('Ethernet1', value: 'access')).to be_truthy
      expect(subject.get('Ethernet1')[:mode]).to eq('access')
    end

    it 'sets the mode value to trunk' do
      node.config(['default interface Ethernet1'])
      expect(subject.get('Ethernet1')[:mode]).to eq('access')
      expect(subject.set_mode('Ethernet1', value: 'trunk')).to be_truthy
      expect(subject.get('Ethernet1')[:mode]).to eq('trunk')
    end
  end

  describe '#set_access_vlan' do
    before { node.config(['default interface Ethernet1', 'vlan 100'])  }

    it 'sets the access vlan value to 100' do
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
      expect(subject.set_access_vlan('Ethernet1', value: '100')).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('100')
    end
  end

  describe '#set_trunk_native_vlan' do
    before { node.config(['default interface Ethernet1', 'vlan 100']) }

    it 'sets the trunk native vlan to 100' do
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
      expect(subject.set_trunk_native_vlan('Ethernet1', value: '100')).to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('100')
    end
  end

  describe '#set_trunk_allowed_vlans' do
    before { node.config(['default interface Ethernet1', 'vlan 100']) }

    it 'sets the trunk allowed vlans' do
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to eq('1-4094')
      expect(subject.set_trunk_allowed_vlans('Ethernet1', value: '1-100')).to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to eq('1-100')
    end
  end
end

