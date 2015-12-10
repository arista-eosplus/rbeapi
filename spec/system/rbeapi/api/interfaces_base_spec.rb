require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/interfaces'

describe Rbeapi::Api::Interfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#respond_to?' do
    it 'test to validate endpoint' do
      expect(subject.respond_to?('get', 'Ethernet1')).to be_truthy
    end
  end

  describe '#get' do
    context 'with interface Loopback' do
      let(:entity) do
        { name: 'Loopback0', type: 'generic', description: '', shutdown: false }
      end

      before { node.config(['no interface Loopback0', 'interface Loopback0']) }

      it 'returns the interface resource' do
        expect(subject.get('Loopback0')).to eq(entity)
      end
    end

    context 'with interface Port-Channel' do
      let(:entity) do
        { name: 'Port-Channel1', type: 'portchannel', description: '',
          shutdown: false, members: [], lacp_mode: 'on', minimum_links: '0',
          lacp_fallback: 'disabled', lacp_timeout: '90' }
      end

      before do
        node.config(['no interface Loopback0', 'no interface Port-Channel1',
                     'interface Port-Channel1'])
      end

      it 'returns the interface resource' do
        expect(subject.get('Port-Channel1')).to eq(entity)
      end
    end

    context 'with interface Vxlan' do
      let(:entity) do
        { name: 'Vxlan1', type: 'vxlan', description: '',
          shutdown: false, source_interface: '', multicast_group: '',
          udp_port: 4789, flood_list: [], vlans: {} }
      end

      before do
        node.config(['no interface Vxlan1', 'interface Vxlan1'])
      end

      it 'returns the interface resource' do
        expect(subject.get('Vxlan1')).to eq(entity)
      end
    end
  end

  describe '#getall' do
    before { node.config(['no interface Loopback0', 'interface Loopback0']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Loopback0')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#create' do
    before { node.config('no interface Loopback0') }

    it 'creates a new interface resource' do
      expect(subject.get('Loopback0')).to be_nil
      expect(subject.create('Loopback0')).to be_truthy
      expect(subject.get('Loopback0')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Loopback0']) }

    it 'deletes a switchport resource' do
      expect(subject.get('Loopback0')).not_to be_nil
      expect(subject.delete('Loopback0')).to be_truthy
      expect(subject.get('Loopback0')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Loopback0', 'shutdown']) }

    it 'sets Loopback0 to default' do
      expect(subject.get('Loopback0')[:shutdown]).to be_truthy
      expect(subject.default('Loopback0')).to be_truthy
      expect(subject.get('Loopback0')[:shutdown]).to be_falsy
    end
  end

  describe '#set_description' do
    it 'sets the description value on the interface' do
      node.config(['interface Loopback0', 'no description'])
      expect(subject.get('Loopback0')[:description]).to be_empty
      expect(subject.set_description('Loopback0', value: 'foo bar'))
        .to be_truthy
      expect(subject.get('Loopback0')[:description]).to eq('foo bar')
    end
  end

  describe '#set_shutdown' do
    it 'shutdown the interface' do
      node.config(['interface Loopback0', 'no shutdown'])
      expect(subject.get('Loopback0')[:shutdown]).to be_falsy
      expect(subject.set_shutdown('Loopback0', enable: false)).to be_truthy
      expect(subject.get('Loopback0')[:shutdown]).to be_truthy
    end

    it 'enable the interface' do
      node.config(['interface Loopback0', 'shutdown'])
      expect(subject.get('Loopback0')[:shutdown]).to be_truthy
      expect(subject.set_shutdown('Loopback0', enable: true)).to be_truthy
      expect(subject.get('Loopback0')[:shutdown]).to be_falsy
    end
  end
end
