require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/ipinterfaces'

describe Rbeapi::Api::Ipinterfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do

    let(:entity) do
      { address: '99.99.99.99/24', mtu: '1500', helper_addresses: [] }
    end

    before { node.config(['default interface Ethernet1', 'interface Ethernet1',
                         'no switchport', 'ip address 99.99.99.99/24']) }

    it 'returns the ipinterface resource' do
      expect(subject.get('Ethernet1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['default interface Ethernet1', 'interface Ethernet1',
                         'no switchport', 'ip address 99.99.99.99/24']) }

    it 'returns the ipinterface collection' do
      expect(subject.getall).to include('Ethernet1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
 end

  describe '#create' do
    before { node.config(['interface Ethernet1', 'switchport']) }

    it 'creates a new ipinterface resource' do
      expect(subject.get('Ethernet1')).to be_nil
      expect(subject.create('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Ethernet1', 'no switchport',
                          'ip address 99.99.99.99/24']) }

    it 'deletes a ipinterface resource' do
      expect(subject.get('Ethernet1')).not_to be_nil
      expect(subject.delete('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).to be_nil
    end
  end

  describe '#set_address' do
    before { node.config(['default interface Ethernet1', 'interface Ethernet1',
                          'no switchport'])  }

    it 'sets the address value' do
      expect(subject.get('Ethernet1')[:address]).to be_empty
      expect(subject.set_address('Ethernet1', value: '99.99.99.99/24')).to be_truthy
      expect(subject.get('Ethernet1')[:address]).to eq('99.99.99.99/24')
    end
  end

  describe '#set_mtu' do
    before { node.config(['default interface Ethernet1', 'interface Ethernet1',
                          'no switchport'])  }

    it 'sets the mtu value on the interface' do
      expect(subject.get('Ethernet1')[:mtu]).to eq('1500')
      expect(subject.set_mtu('Ethernet1', value: '2000')).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('2000')
    end
  end

  describe '#set_trunk_allowed_vlans' do
    before { node.config(['default interface Ethernet1', 'interface Ethernet1',
                          'no switchport', 'ip address 99.99.99.99/24'])  }

    let(:helpers) { %w(99.99.99.98 99.99.99.97) }

    it 'sets the helper addresses on the interface' do
      expect(subject.get('Ethernet1')[:helper_addresses]).to be_empty
      expect(subject.set_helper_addresses('Ethernet1', value: helpers)).to be_truthy
      expect(subject.get('Ethernet1')[:helper_addresses].sort).to eq(helpers.sort)
    end
  end
end

