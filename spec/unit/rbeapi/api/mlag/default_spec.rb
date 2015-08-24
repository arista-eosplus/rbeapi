require 'spec_helper'

require 'rbeapi/api/mlag'

include FixtureHelpers

describe Rbeapi::Api::Mlag do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def mlag
    mlag = Fixtures[:mlag]
    return mlag if mlag
    fixture('mlag', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(mlag)
  end

  describe '#get' do
    let(:keys) { [:global, :interfaces] }

    let(:global_keys) do
      [:domain_id, :local_interface, :peer_address, :peer_link, :shutdown]
    end

    let(:interface_keys) { [:mlag_id] }

    it 'returns the mlag resource hash with all keys' do
      expect(subject.get.keys).to match_array(keys)
    end

    it 'contains the global hash with all keys' do
      expect(subject.get[:global].keys).to match_array(global_keys)
    end

    it 'contains an entry for Port-Channel100' do
      expect(subject.get[:interfaces].keys).to include('Port-Channel100')
    end

    it 'does not contain an entry for Port-Channel10' do
      expect(subject.get[:interfaces].keys).not_to include('Port-Channel10')
    end

    it 'contains all interface keys' do
      interface = subject.get[:interfaces]['Port-Channel100']
      expect(interface.keys).to match_array(interface_keys)
    end
  end

  describe '#set_domain_id' do
    it 'sets the domain_id to foo' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'domain-id foo'])
      expect(subject.set_domain_id(value: 'foo')).to be_truthy
    end

    it 'negates the domain_id' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'no domain-id'])
      expect(subject.set_domain_id(enable: false)).to be_truthy
    end

    it 'defaults the domain_id' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default domain-id'])
      expect(subject.set_domain_id(default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default domain-id'])
      expect(subject.set_domain_id(enable: false, default: true)).to be_truthy
    end
  end

  describe '#set_local_interface' do
    it 'sets the local_interface to foo' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'local-interface Port-Channel1'])
      expect(subject.set_local_interface(value: 'Port-Channel1')).to be_truthy
    end

    it 'negates the local_interface' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'no local-interface'])
      expect(subject.set_local_interface(enable: false)).to be_truthy
    end

    it 'defaults the local_interface' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default local-interface'])
      expect(subject.set_local_interface(default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default local-interface'])
      expect(subject.set_local_interface(enable: false,
                                         default: true)).to be_truthy
    end
  end

  describe '#set_peer_address' do
    it 'sets the peer_address to foo' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'peer-address 1.1.1.1'])
      expect(subject.set_peer_address(value: '1.1.1.1')).to be_truthy
    end

    it 'negates the peer_address' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'no peer-address'])
      expect(subject.set_peer_address(enable: false)).to be_truthy
    end

    it 'defaults the peer_address' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default peer-address'])
      expect(subject.set_peer_address(default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default peer-address'])
      expect(subject.set_peer_address(enable: false,
                                      default: true)).to be_truthy
    end
  end

  describe '#set_peer_link' do
    it 'sets the peer_link to foo' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'peer-link Vlan4094'])
      expect(subject.set_peer_link(value: 'Vlan4094')).to be_truthy
    end

    it 'negates the peer_link' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'no peer-link'])
      expect(subject.set_peer_link(enable: false)).to be_truthy
    end

    it 'defaults the peer_link' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default peer-link'])
      expect(subject.set_peer_link(default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default peer-link'])
      expect(subject.set_peer_link(enable: false, default: true))
        .to be_truthy
    end
  end

  describe '#set_mlag_id' do
    it 'sets the mlag_id to 5' do
      expect(node).to receive(:config).with(['interface Port-Channel1',
                                             'mlag 5'])
      expect(subject.set_mlag_id('Port-Channel1', value: 5)).to be_truthy
    end

    it 'negates the mlag_id' do
      expect(node).to receive(:config).with(['interface Port-Channel1',
                                             'no mlag'])
      expect(subject.set_mlag_id('Port-Channel1', enable: false)).to be_truthy
    end

    it 'defaults the mlag_id' do
      expect(node).to receive(:config).with(['interface Port-Channel1',
                                             'default mlag'])
      expect(subject.set_mlag_id('Port-Channel1', default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Port-Channel1',
                                             'default mlag'])
      expect(subject.set_mlag_id('Port-Channel1', enable: false,
                                                  default: true)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'disables the mlag configuration' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'shutdown'])
      expect(subject.set_shutdown(enable: false)).to be_truthy
    end

    it 'enables the mlag configuration' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'no shutdown'])
      expect(subject.set_shutdown(enable: true)).to be_truthy
    end

    it 'defaults the shutdown value' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default shutdown'])
      expect(subject.set_shutdown(default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['mlag configuration',
                                             'default shutdown'])
      expect(subject.set_shutdown(enable: false, default: true)).to be_truthy
    end
  end
end
