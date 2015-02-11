require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/mlag'

describe Rbeapi::Api::Mlag do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('veos02') }

  describe '#get' do

    let(:entity) do
      { 'domain_id' => '', 'local_interface' => '', 'peer_address' => '',
        'peer_link' => '', 'shutdown' => false, 'interfaces' => {} }
    end

    before { node.config('default mlag configuration') }

    it 'returns the mlag resource' do
      expect(subject.get).to eq(entity)
    end
  end

  describe '#set_domain_id' do
    before { node.config('default mlag configuration') }

    it 'configures the mlag domain-id value' do
      expect(subject.get['domain_id']).to be_empty
      expect(subject.set_domain_id(value: 'foo')).to be_truthy
      expect(subject.get['domain_id']).to eq('foo')
    end
  end

  describe '#set_local_interface' do
    before { node.config(['default mlag configuration', 'interface vlan4094']) }

    it 'configures the mlag local interface value' do
      expect(subject.get['local_interface']).to be_empty
      expect(subject.set_local_interface(value: 'Vlan4094')).to be_truthy
      expect(subject.get['local_interface']).to eq('Vlan4094')
    end
  end

  describe '#set_peer_link' do
    before { node.config(['default mlag configuration',
                          'default interface Ethernet1']) }

    it 'configures the mlag peer link value' do
      expect(subject.get['peer_link']).to be_empty
      expect(subject.set_peer_link(value: 'Ethernet1')).to be_truthy
      expect(subject.get['peer_link']).to eq('Ethernet1')
    end
  end

  describe '#set_peer_address' do
    before { node.config(['default mlag configuration',
                          'default interface Ethernet1']) }

    it 'configures the mlag peer address value' do
      expect(subject.get['peer_address']).to be_empty
      expect(subject.set_peer_address(value: '1.1.1.1')).to be_truthy
      expect(subject.get['peer_address']).to eq('1.1.1.1')
    end
  end

  describe '#set_shutdown' do
    it 'configures mlag to be enabled' do
      node.config(['mlag configuration', 'shutdown'])
      expect(subject.get['shutdown']).to be_truthy
      expect(subject.set_shutdown(value: false)).to be_truthy
      expect(subject.get['shutdown']).to be_falsy
    end

    it 'configures mlag to be disabled' do
      node.config(['mlag configuration', 'no shutdown'])
      expect(subject.get['shutdown']).to be_falsy
      expect(subject.set_shutdown(value: true)).to be_truthy
      expect(subject.get['shutdown']).to be_truthy
    end
  end

  describe '#interfaces' do
    it 'is a kind of MlagInterfaces' do
      expect(subject.interfaces).to be_a_kind_of(Rbeapi::Api::MlagInterfaces)
    end
  end

end
