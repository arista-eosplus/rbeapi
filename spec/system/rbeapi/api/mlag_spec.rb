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

    it 'negates the mlag domain_id' do
      expect(subject.set_domain_id(value: 'foo')).to be_truthy
      expect(subject.get[:global][:domain_id]).to eq('foo')
      expect(subject.set_domain_id(enable: false)).to be_truthy
      expect(subject.get[:global][:domain_id]).to be_empty
    end

    it 'defaults the mlag domain_id' do
      expect(subject.set_domain_id(value: 'foo')).to be_truthy
      expect(subject.get[:global][:domain_id]).to eq('foo')
      expect(subject.set_domain_id(default: true)).to be_truthy
      expect(subject.get[:global][:domain_id]).to be_empty
    end
  end

  describe '#set_local_interface' do
    before { node.config(['default mlag configuration', 'interface vlan4094']) }

    it 'configures the mlag local interface value' do
      expect(subject.get[:global][:local_interface]).to be_empty
      expect(subject.set_local_interface(value: 'Vlan4094')).to be_truthy
      expect(subject.get[:global][:local_interface]).to eq('Vlan4094')
    end

    it 'negates the local interface' do
      expect(subject.set_local_interface(value: 'Vlan4094')).to be_truthy
      expect(subject.get[:global][:local_interface]).to eq('Vlan4094')
      expect(subject.set_local_interface(enable: false)).to be_truthy
      expect(subject.get[:global][:local_interface]).to be_empty
    end

    it 'defaults the local interface' do
      expect(subject.set_local_interface(value: 'Vlan4094')).to be_truthy
      expect(subject.get[:global][:local_interface]).to eq('Vlan4094')
      expect(subject.set_local_interface(default: true)).to be_truthy
      expect(subject.get[:global][:local_interface]).to be_empty
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

    it 'negates the mlag peer link' do
      expect(subject.set_peer_link(value: 'Ethernet1')).to be_truthy
      expect(subject.get[:global][:peer_link]).to eq('Ethernet1')
      expect(subject.set_peer_link(enable: false)).to be_truthy
      expect(subject.get[:global][:peer_link]).to be_empty
    end

    it 'defaults the mlag peer link' do
      expect(subject.set_peer_link(value: 'Ethernet1')).to be_truthy
      expect(subject.get[:global][:peer_link]).to eq('Ethernet1')
      expect(subject.set_peer_link(default: true)).to be_truthy
      expect(subject.get[:global][:peer_link]).to be_empty
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

    it 'negates the mlag peer address' do
      expect(subject.set_peer_address(value: '1.1.1.1')).to be_truthy
      expect(subject.get[:global][:peer_address]).to eq('1.1.1.1')
      expect(subject.set_peer_address(enable: false)).to be_truthy
      expect(subject.get[:global][:peer_address]).to be_empty
    end

    it 'defaults the mlag peer address' do
      expect(subject.set_peer_address(value: '1.1.1.1')).to be_truthy
      expect(subject.get[:global][:peer_address]).to eq('1.1.1.1')
      expect(subject.set_peer_address(default: true)).to be_truthy
      expect(subject.get[:global][:peer_address]).to be_empty
    end
  end

  describe '#set_shutdown' do
    it 'configures mlag to be enabled' do
      node.config(['mlag configuration', 'shutdown'])
      expect(subject.get[:global][:shutdown]).to be_truthy
      expect(subject.set_shutdown(enable: false)).to be_truthy
      expect(subject.get[:global][:shutdown]).to be_falsy
    end

    it 'configures mlag to be disabled' do
      node.config(['mlag configuration', 'no shutdown'])
      expect(subject.get[:global][:shutdown]).to be_falsy
      expect(subject.set_shutdown(enable: true)).to be_truthy
      expect(subject.get[:global][:shutdown]).to be_truthy
    end

    it 'defaults the shutdown value' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default shutdown'])
      expect(subject.set_shutdown(default: true)).to be_truthy
    end
  end

  describe '#set_mlag_id' do
    before do
      node.config(['default mlag configuration',
                   'default interface Ethernet1',
                   'default interface Port-Channel20',
                   'interface Ethernet1',
                   'channel-group 20 mode active',
                   'interface port-channel 20',
                   'mlag 20'])
    end

    it 'configure the mlag id' do
      expect(subject.get[:interfaces]['Port-Channel20'][:mlag_id]).to eq(20)
      expect(subject.set_mlag_id('Port-Channel20', value: '1000')).to be_truthy
      expect(subject.get[:interfaces]['Port-Channel20'][:mlag_id]).to eq(1000)
    end

    it 'negate the mlag id' do
      expect(subject.get[:interfaces]['Port-Channel20'][:mlag_id]).to eq(20)
      expect(subject.set_mlag_id('Port-Channel20', enable: false)).to be_truthy
      expect(subject.get[:interfaces]['Port-Channel20']).to eq(nil)
    end

    it 'default the mlag id' do
      expect(subject.get[:interfaces]['Port-Channel20'][:mlag_id]).to eq(20)
      expect(subject.set_mlag_id('Port-Channel20', default: true)).to be_truthy
      expect(subject.get[:interfaces]['Port-Channel20']).to eq(nil)
    end
  end
end
