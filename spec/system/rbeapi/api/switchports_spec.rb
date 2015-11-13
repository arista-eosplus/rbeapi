require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/switchports'

describe Rbeapi::Api::Switchports do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:keys) do
      [:mode, :access_vlan, :trunk_native_vlan, :trunk_allowed_vlans]
    end

    before do
      node.config(['default interface Ethernet1', 'interface Ethernet2',
                   'no switchport'])
    end

    it 'returns the switchport resource' do
      expect(subject.get('Ethernet1')).not_to be_nil
    end

    it 'does not return a nonswitchport resource' do
      expect(subject.get('Ethernet2')).to be_nil
    end

    it 'has all required keys' do
      expect(subject.get('Ethernet1').keys).to eq(keys)
    end

    it 'returns allowed_vlans as an array' do
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans])
        .to be_a_kind_of(Array)
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

    it 'negate the mode value' do
      node.config(['interface Ethernet1', 'switchport mode trunk'])
      expect(subject.get('Ethernet1')[:mode]).to eq('trunk')
      expect(subject.set_mode('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:mode]).to eq('access')
    end

    it 'default the mode value' do
      node.config(['interface Ethernet1', 'switchport mode trunk'])
      expect(subject.get('Ethernet1')[:mode]).to eq('trunk')
      expect(subject.set_mode('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:mode]).to eq('access')
    end
  end

  describe '#set_access_vlan' do
    before { node.config(['default interface Ethernet1', 'vlan 100']) }

    it 'sets the access vlan value to 100' do
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
      expect(subject.set_access_vlan('Ethernet1', value: '100')).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('100')
    end

    it 'negates the access vlan value' do
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
      expect(subject.set_access_vlan('Ethernet1', value: '100')).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('100')
      expect(subject.set_access_vlan('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
    end

    it 'defaults the access vlan value' do
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
      expect(subject.set_access_vlan('Ethernet1', value: '100')).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('100')
      expect(subject.set_access_vlan('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:access_vlan]).to eq('1')
    end
  end

  describe '#set_trunk_native_vlan' do
    before { node.config(['default interface Ethernet1', 'vlan 100']) }

    it 'sets the trunk native vlan to 100' do
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
      expect(subject.set_trunk_native_vlan('Ethernet1', value: '100'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('100')
    end

    it 'negates the trunk native vlan' do
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
      expect(subject.set_trunk_native_vlan('Ethernet1', value: '100'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('100')
      expect(subject.set_trunk_native_vlan('Ethernet1', enable: false))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
    end

    it 'defaults the trunk native vlan' do
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
      expect(subject.set_trunk_native_vlan('Ethernet1', value: '100'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('100')
      expect(subject.set_trunk_native_vlan('Ethernet1', default: true))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_native_vlan]).to eq('1')
    end
  end

  describe '#set_trunk_allowed_vlans' do
    before { node.config(['default interface Ethernet1', 'vlan 100']) }

    it 'raises an ArgumentError if value is not an array' do
      expect { subject.set_trunk_allowed_vlans('Ethernet1', value: '1-100') }
        .to raise_error(ArgumentError)
    end

    it 'sets vlan 8 and 9 to the trunk allowed vlans' do
      node.config(['interface Ethernet1', 'switchport trunk allowed vlan none'])
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to be_empty
      expect(subject.set_trunk_allowed_vlans('Ethernet1', value: [8, 9]))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to eq([8, 9])
    end

    it 'negate switchport trunk allowed vlan' do
      node.config(['interface Ethernet1', 'switchport trunk allowed vlan none'])
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to be_empty
      expect(subject.set_trunk_allowed_vlans('Ethernet1', value: [8, 9]))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to eq([8, 9])
      expect(subject.set_trunk_allowed_vlans('Ethernet1', enable: false))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans].length).to eq(4094)
    end

    it 'default switchport trunk allowed vlan' do
      node.config(['interface Ethernet1', 'switchport trunk allowed vlan none'])
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to be_empty
      expect(subject.set_trunk_allowed_vlans('Ethernet1', value: [8, 9]))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans]).to eq([8, 9])
      expect(subject.set_trunk_allowed_vlans('Ethernet1', default: true))
        .to be_truthy
      expect(subject.get('Ethernet1')[:trunk_allowed_vlans].length).to eq(4094)
    end
  end
end
