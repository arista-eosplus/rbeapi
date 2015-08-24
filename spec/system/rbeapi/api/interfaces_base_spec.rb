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
      { name: 'Loopback0', type: 'generic', description: '', shutdown: false }
    end

    before { node.config(['no interface Loopback0', 'interface Loopback0']) }

    it 'returns the interface resource' do
      expect(subject.get('Loopback0')).to eq(entity)
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
