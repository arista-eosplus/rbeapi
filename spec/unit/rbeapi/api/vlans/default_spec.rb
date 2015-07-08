require 'spec_helper'

require 'rbeapi/api/vlans'

include FixtureHelpers

describe Rbeapi::Api::Vlans do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def vlans
    vlans = Fixtures[:vlans]
    return vlans if vlans
    fixture('vlans', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(vlans)
  end

  describe '#get' do
    let(:entity) do
      { name: 'default', state: 'active', trunk_groups: [] }
    end

    it 'returns the vlan resource' do
      expect(subject.get('1')).to eq(entity)
    end
  end

  describe '#getall' do
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
    it 'creates a new vlan resource' do
      expect(node).to receive(:config).with('vlan 1234')
      expect(subject.create('1234')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes a vlan resource' do
      expect(node).to receive(:config).with('no vlan 1234')
      expect(subject.delete('1234')).to be_truthy
    end
  end

  describe '#default' do
    it 'sets vlan 1 to default' do
      expect(node).to receive(:config).with('default vlan 1234')
      expect(subject.default('1234')).to be_truthy
    end
  end

  describe '#set_name' do
    it 'sets vlan 1 name to foo' do
      expect(node).to receive(:config).with(['vlan 1', 'name foo'])
      expect(subject.set_name('1', value: 'foo')).to be_truthy
    end

    it 'negates vlan name' do
      expect(node).to receive(:config).with(['vlan 1', 'no name'])
      expect(subject.set_name('1')).to be_truthy
    end

    it 'defaults the vlan name' do
      expect(node).to receive(:config).with(['vlan 1', 'default name'])
      expect(subject.set_name('1', default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['vlan 1', 'default name'])
      expect(subject.set_name('1', value: 'foo', default: true)).to be_truthy
    end
  end

  describe '#set_state' do
    it 'sets vlan 1 state to suspend' do
      expect(node).to receive(:config).with(['vlan 1', 'state suspend'])
      expect(subject.set_state('1', value: 'suspend')).to be_truthy
    end

    it 'sets vlan 1 state to active' do
      expect(node).to receive(:config).with(['vlan 1', 'state active'])
      expect(subject.set_state('1', value: 'active')).to be_truthy
    end

    it 'negates the state' do
      expect(node).to receive(:config).with(['vlan 1', 'no state'])
      expect(subject.set_state('1')).to be_truthy
    end

    it 'defaults the state' do
      expect(node).to receive(:config).with(['vlan 1', 'default state'])
      expect(subject.set_state('1', default: true)).to be_truthy
    end

    it 'default option take precedence' do
      expect(node).to receive(:config).with(['vlan 1', 'default state'])
      expect(subject.set_state('1', value: 'active', default: true)).to \
        be_truthy
    end

    it 'raises ArgumentError for invalid state' do
      expect { subject.set_state('1', value: 'foo') }.to \
        raise_error ArgumentError
    end
  end

  describe '#add_trunk_group' do
    it 'adds trunk group foo to vlan 1' do
      expect(node).to receive(:config).with(['vlan 1', 'trunk group foo'])
      expect(subject.add_trunk_group('1', 'foo')).to be_truthy
    end
  end

  describe '#remove_trunk_group' do
    it 'removes trunk group foo from vlan 1' do
      expect(node).to receive(:config).with(['vlan 1', 'no trunk group foo'])
      expect(subject.remove_trunk_group('1', 'foo')).to be_truthy
    end
  end
end
