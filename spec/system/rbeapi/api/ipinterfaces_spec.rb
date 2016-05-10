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
      { address: '77.99.99.99/24', mtu: '1500', helper_addresses: [], load_interval: '' }
    end

    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1',
                   'no switchport', 'ip address 77.99.99.99/24'])
    end

    it 'returns the ipinterface resource' do
      expect(subject.get('Ethernet1')).to eq(entity)
    end
  end

  describe '#getall' do
    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1',
                   'no switchport', 'ip address 77.99.99.99/24'])
    end

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
    before do
      node.config(['interface Ethernet1', 'no switchport',
                   'ip address 77.99.99.99/24'])
    end

    it 'deletes a ipinterface resource' do
      expect(subject.get('Ethernet1')).not_to be_nil
      expect(subject.delete('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')).to be_nil
    end
  end

  describe '#set_address' do
    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1',
                   'no switchport'])
    end

    it 'sets the address value' do
      expect(subject.get('Ethernet1')[:address]).to be_empty
      expect(subject.set_address('Ethernet1', value: '77.99.99.99/24'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:address]).to eq('77.99.99.99/24')
    end

    it 'negates the address value' do
      expect(subject.set_address('Ethernet1', value: '77.99.99.99/24'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:address]).to eq('77.99.99.99/24')
      expect(subject.set_address('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:address]).to be_empty
    end

    it 'defaults the address value' do
      expect(subject.set_address('Ethernet1', value: '77.99.99.99/24'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:address]).to eq('77.99.99.99/24')
      expect(subject.set_address('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:address]).to be_empty
    end
  end

  describe '#set_mtu' do
    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1',
                   'no switchport'])
    end

    it 'sets the mtu value on the interface' do
      expect(subject.get('Ethernet1')[:mtu]).to eq('1500')
      expect(subject.set_mtu('Ethernet1', value: '2000')).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('2000')
    end

    it 'negates the mtu' do
      expect(subject.set_mtu('Ethernet1', value: '2000')).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('2000')
      expect(subject.set_mtu('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('1500')
    end

    it 'defaults the mtu' do
      expect(subject.set_mtu('Ethernet1', value: '2000')).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('2000')
      expect(subject.set_mtu('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:mtu]).to eq('1500')
    end
  end

  describe '#set_helper_addresses' do
    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1',
                   'no switchport', 'ip address 77.99.99.99/24'])
    end

    let(:helpers) { %w(77.99.99.98 77.99.99.97) }

    it 'sets the helper addresses on the interface' do
      expect(subject.get('Ethernet1')[:helper_addresses]).to be_empty
      expect(subject.set_helper_addresses('Ethernet1', value: helpers))
        .to be_truthy
      expect(subject.get('Ethernet1')[:helper_addresses].sort)
        .to eq(helpers.sort)
    end

    it 'negates the helper addresses on the interface' do
      expect(subject.get('Ethernet1')[:helper_addresses]).to be_empty
      expect(subject.set_helper_addresses('Ethernet1', enable: false))
        .to be_truthy
      expect(subject.get('Ethernet1')[:helper_addresses].sort).to be_empty
    end

    it 'default the helper addresses on the interface' do
      expect(subject.get('Ethernet1')[:helper_addresses]).to be_empty
      expect(subject.set_helper_addresses('Ethernet1', default: true))
        .to be_truthy
      expect(subject.get('Ethernet1')[:helper_addresses].sort).to be_empty
    end

    it 'raises an ArgumentError if opts value is not an array' do
      expect { subject.set_helper_addresses('Ethernet1', value: '123') }
        .to raise_error(ArgumentError)
    end
  end

  describe '#set_load_interval' do
    before do
      node.config(['default interface Ethernet1', 'interface Ethernet1', 'no switchport'])
    end

    it 'sets the load-interval value on the interface' do
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
      expect(subject.set_load_interval('Ethernet1', value: '10')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('10')
    end

    it 'negates the load-interval' do
      expect(subject.set_load_interval('Ethernet1', value: '20')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('20')
      expect(subject.set_load_interval('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
    end

    it 'defaults the load-interval' do
      expect(subject.set_load_interval('Ethernet1', value: '10')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('10')
      expect(subject.set_load_interval('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
    end
  end
end
