require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/varp'

describe Rbeapi::Api::Varp do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('dut') }

  describe '#get' do
    it 'returns a varp resource instance' do
      expect(subject.get).to be_a_kind_of(Hash)
    end

    it 'has a key for mac_address' do
      expect(subject.get).to include('mac_address')
    end

    it 'has a key for interfaces' do
      expect(subject.get).to include('interfaces')
    end
  end

  describe '#interfaces' do
    it 'is a kind of VarpInterfaces' do
      expect(subject.interfaces).to be_a_kind_of(Rbeapi::Api::VarpInterfaces)
    end
  end

  describe '#set_router_id' do
    before { node.config('no ip virtual-router mac-address') }

    it 'configures the ip varp mac-address' do
      expect(subject.get['mac_address']).to be_empty
      expect(subject.set_mac_address(value: 'aa:bb:cc:dd:ee:ff')).to be_truthy
      expect(subject.get['mac_address']).to eq('aa:bb:cc:dd:ee:ff')
    end
  end
end
