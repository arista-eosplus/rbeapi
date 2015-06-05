require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/vlans'

describe Rbeapi::Api::Vlans do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  context '#get' do
    describe 'with defaults' do
      let(:entity) do
        { name: 'default', state: 'active', trunk_groups: [] }
      end

      before { node.config(['no vlan 1-4094', 'vlan 1']) }

      it 'returns the vlan resource' do
        expect(subject.get('1')).to eq(entity)
      end
    end

    describe 'validate name parser' do
      let(:entity) do
        { name: 'test-vlan', state: 'active', trunk_groups: [] }
      end

      before { node.config(['no vlan 1-4094', 'vlan 1', 'name test-vlan']) }

      it 'returns the vlan resource' do
        expect(subject.get('1')).to eq(entity)
      end
    end
  end

  describe '#getall' do
    before { node.config(['no vlan 1-4094', 'vlan 1']) }

    it 'returns the vlan collection' do
      expect(subject.getall).to include('1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has only one entry' do
      expect(subject.getall.size).to eq(1)
    end
  end

  describe '#create' do
    before { node.config('no vlan 1234') }

    it 'creates a new vlan resource' do
      expect(subject.get('1234')).to be_nil
      expect(subject.create('1234')).to be_truthy
      expect(subject.get('1234')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config('vlan 1234') }

    it 'deletes a vlan resource' do
      expect(subject.get('1234')).not_to be_nil
      expect(subject.delete('1234')).to be_truthy
      expect(subject.get('1234')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['vlan 1']) }

    it 'sets vlan 1 to default' do
      expect(subject.get('1')).not_to be_nil
      expect(subject.default('1')).to be_truthy
      expect(subject.get('1')).to be_nil
    end
  end

  describe '#set_name' do
    before { node.config(['default vlan 1', 'vlan 1']) }

    it 'sets vlan 1 name to foo' do
      expect(subject.get('1')[:name]).to eq('default')
      expect(subject.set_name('1', value: 'foo')).to be_truthy
      expect(subject.get('1')[:name]).to eq('foo')
    end
  end

  describe '#set_state' do
    it 'sets vlan 1 state to suspend' do
      node.config(['default vlan 1', 'vlan 1'])
      expect(subject.get('1')[:state]).to eq('active')
      expect(subject.set_state('1', value: 'suspend')).to be_truthy
      expect(subject.get('1')[:state]).to eq('suspend')
    end

    it 'sets vlan 1 state to active' do
      node.config(['vlan 1', 'state suspend'])
      expect(subject.get('1')[:state]).to eq('suspend')
      expect(subject.set_state('1', value: 'active')).to be_truthy
      expect(subject.get('1')[:state]).to eq('active')
    end
  end

  describe '#add_trunk_group' do
    before { node.config(['default vlan 1', 'vlan 1']) }

    it 'adds trunk group foo to vlan 1' do
      expect(subject.get('1')[:trunk_groups]).not_to include('foo')
      expect(subject.add_trunk_group('1', 'foo')).to be_truthy
      expect(subject.get('1')[:trunk_groups]).to include('foo')
    end
  end

  describe '#remove_trunk_group' do
    before { node.config(['vlan 1', 'trunk group foo']) }

    it 'removes trunk group foo from vlan 1' do
      expect(subject.get('1')[:trunk_groups]).to include('foo')
      expect(subject.remove_trunk_group('1', 'foo')).to be_truthy
      expect(subject.get('1')[:trunk_groups]).not_to include('foo')
    end
  end
end
