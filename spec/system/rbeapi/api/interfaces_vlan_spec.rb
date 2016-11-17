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
      { name: 'Vlan1', type: 'vlan', description: '', shutdown: false, autostate: :true, load_interval: '', encapsulation: "" }
    end

    before { node.config(['no interface Vlan1', 'interface Vlan1']) }

    it 'returns the interface resource' do
      expect(subject.get('Vlan1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['no interface Vlan1', 'interface Vlan1']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Vlan1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#create' do
    before { node.config('no interface Vlan1') }

    it 'creates a new interface resource' do
      expect(subject.create('Vlan1')).to be_truthy
      expect(subject.get('Vlan1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Vlan1']) }

    it 'deletes a vlan interface resource' do
      expect(subject.get('Vlan1')).not_to be_nil
      expect(subject.delete('Vlan1')).to be_truthy
      expect(subject.get('Vlan1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Vlan1', 'shutdown']) }

    it 'sets Vlan1 to default' do
      expect(subject.get('Vlan1')[:shutdown]).to be_truthy
      expect(subject.default('Vlan1')).to be_truthy
      expect(subject.get('Vlan1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_autostate' do

    it 'sets the autostate value to true' do
      node.config(['interface Vlan1', 'no autostate'])
      expect(subject.get('Vlan1')[:autostate]).to eq(:false)
      expect(subject.set_autostate('Vlan1', value: :true)).to be_truthy
      expect(subject.get('Vlan1')[:autostate]).to eq(:true)
    end

    it 'sets the autostate value to false' do
      node.config(['interface Vlan1', 'autostate'])
      expect(subject.get('Vlan1')[:autostate]).to be_truthy
      expect(subject.set_autostate('Vlan1', value: :false)).to be_truthy
      expect(subject.get('Vlan1')[:autostate]).to eq(:false)
    end

    it 'manages autostate default' do
      node.config(['interface Vlan1', 'no autostate'])
      expect(subject.get('Vlan1')[:autostate]).to eq(:false)
      expect(subject.set_autostate('Vlan1', default: :true)).to be_truthy
      expect(subject.get('Vlan1')[:autostate]).to eq(:true)
    end
  end
end
