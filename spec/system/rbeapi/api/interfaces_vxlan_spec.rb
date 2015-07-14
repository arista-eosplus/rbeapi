require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/interfaces'

describe Rbeapi::Api::Interfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { name: 'Vxlan1', type: 'vxlan', description: '', shutdown: false,
        source_interface: '', multicast_group: '', udp_port: 4789,
        flood_list: [], vlans: {} }
    end

    before { node.config(['no interface Vxlan1', 'interface Vxlan1']) }

    it 'returns the interface resource' do
      expect(subject.get('Vxlan1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['no interface Vxlan1', 'interface Vxlan1']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Vxlan1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#create' do
    before { node.config('no interface Vxlan1') }

    it 'creates a new interface resource' do
      expect(subject.get('Vxlan1')).to be_nil
      expect(subject.create('Vxlan1')).to be_truthy
      expect(subject.get('Vxlan1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Vxlan1']) }

    it 'deletes a vxlan interface resource' do
      expect(subject.get('Vxlan1')).not_to be_nil
      expect(subject.delete('Vxlan1')).to be_truthy
      expect(subject.get('Vxlan1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Vxlan1', 'shutdown']) }

    it 'sets Vxlan1 to default' do
      expect(subject.get('Vxlan1')[:shutdown]).to be_truthy
      expect(subject.default('Vxlan1')).to be_truthy
      expect(subject.get('Vxlan1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_description' do
    it 'sets the description value on the interface' do
      node.config(['interface Vxlan1', 'no description'])
      expect(subject.get('Vxlan1')[:description]).to be_empty
      expect(subject.set_description('Vxlan1', value: 'foo bar')).to be_truthy
      expect(subject.get('Vxlan1')[:description]).to eq('foo bar')
    end
  end

  describe '#set_shutdown' do
    it 'sets the shutdown value to true' do
      node.config(['interface Vxlan1', 'no shutdown'])
      expect(subject.get('Vxlan1')[:shutdown]).to be_falsy
      expect(subject.set_shutdown('Vxlan1', enable: true)).to be_truthy
      expect(subject.get('Vxlan1')[:shutdown]).to be_truthy
    end

    it 'sets the shutdown value to false' do
      node.config(['interface Vxlan1', 'shutdown'])
      expect(subject.get('Vxlan1')[:shutdown]).to be_truthy
      expect(subject.set_shutdown('Vxlan1', enable: false)).to be_truthy
      expect(subject.get('Vxlan1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_source_interface' do
    before { node.config(['no interface Vxlan1', 'interface Vxlan1']) }

    it 'sets the source interface value on the interface' do
      expect(subject.get('Vxlan1')[:source_interface]).to be_empty
      expect(subject.set_source_interface('Vxlan1', value: 'Loopback0'))
        .to be_truthy
      expect(subject.get('Vxlan1')[:source_interface]).to eq('Loopback0')
    end
  end

  describe '#set_multicast_group' do
    before { node.config(['no interface Vxlan1', 'interface Vxlan1']) }

    it 'sets the multicast group value on the interface' do
      expect(subject.get('Vxlan1')[:multicast_group]).to be_empty
      expect(subject.set_multicast_group('Vxlan1', value: '239.10.10.10'))
        .to be_truthy
      expect(subject.get('Vxlan1')[:multicast_group]).to eq('239.10.10.10')
    end
  end
end
