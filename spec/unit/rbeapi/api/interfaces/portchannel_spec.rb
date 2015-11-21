require 'spec_helper'

require 'rbeapi/api/interfaces'

include FixtureHelpers

describe Rbeapi::Api::PortchannelInterface do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def interfaces
    interfaces = Fixtures[:interfaces]
    return interfaces if interfaces
    fixture('interfaces', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(interfaces)
  end

  describe '#get' do
    before :each do
      allow(subject.node).to receive(:enable)
        .with(include('show port-channel'), encoding: 'text')
        .and_return([{ result:
                       { 'output' => "Port Channel Port-Channel1:\n  Active " \
                                     'Ports: Ethernet1 PeerEthernet1 ' \
                                     "Ethernet51/1 \n\n" } }])
    end
    let(:resource) { subject.get('Port-Channel1') }

    let(:keys) do
      [:type, :shutdown, :description, :name, :members, :lacp_mode,
       :minimum_links, :lacp_timeout, :lacp_fallback]
    end

    it 'returns an ethernet resource as a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'returns an interface type of portchannel' do
      expect(resource[:type]).to eq('portchannel')
    end

    it 'has all keys' do
      expect(resource.keys).to match_array(keys)
    end

    it 'does not return PeerEthernet members' do
      expect(resource[:members]).to_not include 'PeerEthernet'
    end

    it 'returns 1 member' do
      expect(resource[:members]).to contain_exactly('Ethernet1', 'Ethernet51/1')
    end
  end

  describe '#create' do
    it 'creates the interface in the config' do
      expect(node).to receive(:config).with('interface Port-Channel1')
      expect(subject.create('Port-Channel1')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes the interface in the config' do
      expect(node).to receive(:config).with('no interface Port-Channel1')
      expect(subject.delete('Port-Channel1')).to be_truthy
    end
  end

  describe '#default' do
    it 'defaults the interface config' do
      expect(node).to receive(:config).with('default interface Port-Channel1')
      expect(subject.default('Port-Channel1')).to be_truthy
    end
  end

  describe '#set_description' do
    it 'sets the interface description' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'description test string'])

      expect(subject.set_description('Port-Channel1', value: 'test string'))
        .to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'no description'])

      expect(subject.set_description('Port-Channel1',
                                     enable: false)).to be_truthy
    end

    it 'defaults the interface description' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'default description'])

      expect(subject.set_description('Port-Channel1', default: true))
        .to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'default description'])

      opts = { enable: false, default: true }
      expect(subject.set_description('Port-Channel1', opts)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enables the interface' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'no shutdown'])

      expect(subject.set_shutdown('Port-Channel1', enable: true)).to be_truthy
    end

    it 'disables the interface' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'shutdown'])

      expect(subject.set_shutdown('Port-Channel1', enable: false)).to be_truthy
    end

    it 'defaults the interface state' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'default shutdown'])

      expect(subject.set_shutdown('Port-Channel1', default: true)).to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config)
        .with(['interface Port-Channel1', 'default shutdown'])

      opts = { enable: false, default: true }
      expect(subject.set_shutdown('Port-Channel1', opts)).to be_truthy
    end
  end
end
