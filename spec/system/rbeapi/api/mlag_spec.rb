require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/mlag'

describe Rbeapi::Api::Mlag do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:global_keys) do
      [:domain_id, :local_interface, :peer_address, :peer_link, :shutdown]
    end

    before { node.config('default mlag configuration') }

    it 'contains all required global keys' do
      global_keys.each do |key|
        expect(subject.get[:global]).to include(key)
      end
      expect(subject.get).to include(:interfaces)
    end
  end

  describe '#set_domain_id' do
    before { node.config('default mlag configuration') }

    it 'configures the mlag domain-id value' do
      expect(subject.get[:global][:domain_id]).to be_empty
      expect(subject.set_domain_id(value: 'foo')).to be_truthy
      expect(subject.get[:global][:domain_id]).to eq('foo')
    end
  end

  describe '#set_local_interface' do
    before { node.config(['default mlag configuration', 'interface vlan4094']) }

    it 'configures the mlag local interface value' do
      expect(subject.get[:global][:local_interface]).to be_empty
      expect(subject.set_local_interface(value: 'Vlan4094')).to be_truthy
      expect(subject.get[:global][:local_interface]).to eq('Vlan4094')
    end
  end

  describe '#set_peer_link' do
    before do
      node.config(['default mlag configuration',
                   'default interface Ethernet1'])
    end

    it 'configures the mlag peer link value' do
      expect(subject.get[:global][:peer_link]).to be_empty
      expect(subject.set_peer_link(value: 'Ethernet1')).to be_truthy
      expect(subject.get[:global][:peer_link]).to eq('Ethernet1')
    end
  end

  describe '#set_peer_address' do
    before do
      node.config(['default mlag configuration',
                   'default interface Ethernet1'])
    end

    it 'configures the mlag peer address value' do
      expect(subject.get[:global][:peer_address]).to be_empty
      expect(subject.set_peer_address(value: '1.1.1.1')).to be_truthy
      expect(subject.get[:global][:peer_address]).to eq('1.1.1.1')
    end
  end

  describe '#set_shutdown' do
    it 'configures mlag to be enabled' do
      node.config(['mlag configuration', 'shutdown'])
      expect(subject.get[:global][:shutdown]).to be_truthy
      expect(subject.set_shutdown(value: false)).to be_truthy
      expect(subject.get[:global][:shutdown]).to be_falsy
    end

    it 'configures mlag to be disabled' do
      node.config(['mlag configuration', 'no shutdown'])
      expect(subject.get[:global][:shutdown]).to be_falsy
      expect(subject.set_shutdown(value: true)).to be_truthy
      expect(subject.get[:global][:shutdown]).to be_truthy
    end
  end
end
