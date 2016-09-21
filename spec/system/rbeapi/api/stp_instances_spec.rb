require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/stp'

describe Rbeapi::Api::StpInstances do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    before do
      node.config(['spanning-tree mode mstp',
                   'spanning-tree mst configuration',
                   'instance 10 vlans 100', 'exit'])
    end

    it 'returns the stp instance resource as a hash' do
      expect(subject.get('10')).to be_a_kind_of(Hash)
    end

    it 'returns the default stp instance resources as a hash' do
      expect(subject.get('0')).to be_a_kind_of(Hash)
      expect(subject.get('1')).to be_a_kind_of(Hash)
    end

    it 'returns the instance priority' do
      expect(subject.get('10')).to include(:priority)
    end

    it 'returns the default instances priority' do
      expect(subject.get('0')).to include(:priority)
      expect(subject.get('1')).to include(:priority)
    end
  end

  describe '#getall' do
    before do
      node.config(['no spanning-tree mode mstp', 'spanning-tree mode mstp'])
    end

    it 'returns a kind of hash' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#delete' do
    before do
      node.config(['spanning-tree mode mstp',
                   'spanning-tree mst configuration',
                   'instance 1 vlans 1',
                   'instance 10 vlans 100', 'exit'])
    end

    it 'deletes the mst instance' do
      expect(subject.get('10')).not_to be_nil
      expect(subject.delete('10')).to be_truthy
      expect(subject.get('10')).to be_nil
    end

    it 'does not delete the default mst instance' do
      expect(subject.get('1')).not_to be_nil
      expect(subject.delete('1')).to be_truthy
      expect(subject.get('1')).not_to be_nil
    end
  end

  describe '#set_priority' do
    before do
      node.config(['default spanning-tree mst 10 priority',
                   'no spanning-tree mst 1 priority',
                   'spanning-tree mode mstp',
                   'default spanning-tree mst configuration',
                   'spanning-tree mst configuration',
                   'instance 10 vlans 100', 'exit'])
    end

    it 'set the instance priority' do
      expect(subject.get('10')[:priority]).to eq('32768')
      expect(subject.set_priority('10', value: '16384')).to be_truthy
      expect(subject.get('10')[:priority]).to eq('16384')
    end

    it 'set the default instance priority' do
      expect(subject.get('1')[:priority]).to eq('32768')
      expect(subject.set_priority('1', value: '4096')).to be_truthy
      expect(subject.get('1')[:priority]).to eq('4096')
    end

    it 'set the instance priority to default' do
      expect(subject.set_priority('10', value: '16384',
                                        default: true)).to be_truthy
      expect(subject.get('10')[:priority]).to eq('32768')
    end

    it 'set the default instance priority to default' do
      expect(subject.set_priority('1', value: '4096',
                                       default: true)).to be_truthy
      expect(subject.get('1')[:priority]).to eq('32768')
    end

    it 'set the instance priority to enable false' do
      expect(subject.set_priority('10', value: '16384',
                                        default: false,
                                        enable: false)).to be_truthy
      expect(subject.get('10')[:priority]).to eq('32768')
    end

    it 'set the default instance priority to enable false' do
      expect(subject.set_priority('1', value: '4096',
                                       default: false,
                                       enable: false)).to be_truthy
      expect(subject.get('1')[:priority]).to eq('32768')
    end

    it 'set the instance priority to enable true' do
      expect(subject.set_priority('10', value: '16384',
                                        default: false,
                                        enable: true)).to be_truthy
      expect(subject.get('10')[:priority]).to eq('16384')
    end

    it 'set the default instance priority to enable true' do
      expect(subject.set_priority('1', value: '4096',
                                       default: false,
                                       enable: true)).to be_truthy
      expect(subject.get('1')[:priority]).to eq('4096')
    end
  end
end
