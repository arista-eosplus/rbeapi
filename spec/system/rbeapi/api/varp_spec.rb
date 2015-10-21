require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/varp'

describe Rbeapi::Api::Varp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:resource) { subject.get }

    before do
      node.config(['no ip virtual-router mac-address',
                   'no interface Vlan99', 'no interface Vlan100',
                   'ip virtual-router mac-address aa:bb:cc:dd:ee:ff',
                   'interface Vlan99', 'interface Vlan100'])
    end

    it 'returns a varp resource instance' do
      expect(subject.get).to be_a_kind_of(Hash)
    end

    it 'has a key for mac_address' do
      expect(subject.get).to include(:mac_address)
    end

    it 'has a key for interfaces' do
      expect(subject.get).to include(:interfaces)
    end
  end

  describe '#interfaces' do
    it 'is a kind of VarpInterfaces' do
      expect(subject.interfaces).to be_a_kind_of(Rbeapi::Api::VarpInterfaces)
    end
  end

  describe '#set_mac_address' do
    before { node.config('no ip virtual-router mac-address') }

    it 'configures the virtual-router mac-address' do
      expect(subject.get[:mac_address]).to be_empty
      expect(subject.set_mac_address(value: 'aa:bb:cc:dd:ee:ff')).to be_truthy
      expect(subject.get[:mac_address]).to eq('aa:bb:cc:dd:ee:ff')
    end
  end
end
