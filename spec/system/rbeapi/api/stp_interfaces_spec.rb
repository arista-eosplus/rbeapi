require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/stp'

describe Rbeapi::Api::StpInterfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { portfast: false, portfast_type: 'normal', bpduguard: false }
    end

    before { node.config('default interface Ethernet1') }

    it 'returns the stp interface resource' do
      expect(subject.get('Ethernet1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config('default interface Ethernet1') }

    it 'includes interface ethernet1' do
      expect(subject.getall).to include('Ethernet1')
    end

    it 'returns a kind of hash' do
      expect(subject.get('Ethernet1')).to be_a_kind_of(Hash)
    end
  end

  describe '#set_portfast' do
    it 'enables portfast' do
      node.config(['interface Ethernet1', 'no spanning-tree portfast'])
      expect(subject.get('Ethernet1')[:portfast]).to be_falsy
      expect(subject.set_portfast('Ethernet1', enable: true)).to be_truthy
      expect(subject.get('Ethernet1')[:portfast]).to be_truthy
    end

    it 'disable portfast' do
      node.config(['interface Ethernet1', 'spanning-tree portfast'])
      expect(subject.get('Ethernet1')[:portfast]).to be_truthy
      expect(subject.set_portfast('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:portfast]).to be_falsy
    end

    it 'sets portfast to default value' do
      node.config(['interface Ethernet1', 'spanning-tree portfast'])
      expect(subject.get('Ethernet1')[:portfast]).to be_truthy
      expect(subject.set_portfast('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:portfast]).to be_falsy
    end
  end

  describe '#set_portfast_type' do
    it 'raises an ArgumentError if value is not set' do
      expect { subject.set_portfast_type('Ethernet1') }
        .to raise_error(ArgumentError)
    end

    it 'enables portfast type' do
      node.config(['interface Ethernet1', 'no spanning-tree portfast'])
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('normal')
      expect(subject.set_portfast_type('Ethernet1', value: 'edge')).to be_truthy
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('edge')
    end

    it 'disable portfast' do
      node.config(['interface Ethernet1', 'spanning-tree portfast edge'])
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('edge')
      expect(subject.set_portfast_type('Ethernet1', value: 'edge',
                                                    enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('normal')
    end

    it 'sets portfast to default value' do
      node.config(['interface Ethernet1', 'spanning-tree portfast network'])
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('network')
      expect(subject.set_portfast_type('Ethernet1', value: 'network',
                                                    default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:portfast_type]).to eq('normal')
    end
  end

  describe '#set_bpduguard' do
    it 'sets the bpduguard value to true' do
      node.config(['interface Ethernet1', 'no spanning-tree bpduguard'])
      expect(subject.get('Ethernet1')[:bpduguard]).to be_falsy
      expect(subject.set_bpduguard('Ethernet1', enable: true)).to be_truthy
      expect(subject.get('Ethernet1')[:bpduguard]).to be_truthy
    end

    it 'sets the bpduguard value to false' do
      node.config(['interface Ethernet1', 'spanning-tree bpduguard enable'])
      expect(subject.get('Ethernet1')[:bpduguard]).to be_truthy
      expect(subject.set_bpduguard('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:bpduguard]).to be_falsy
    end
  end
end
