require 'spec_helper'

require 'rbeapi/api/interfaces'

include FixtureHelpers

describe Rbeapi::Api::VlanInterface do
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
    let(:resource) { subject.get('Vlan1') }

    let(:keys) do
      [:type, :shutdown, :load_interval, :description, :name, :autostate,
       :encapsulation]
    end

    it 'returns the resource as a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'returns an interface type of vlan' do
      expect(resource[:type]).to eq('vlan')
    end

    it 'has all keys' do
      expect(resource.keys).to match_array(keys)
    end
  end

  describe '#create' do
    it 'creates the interface in the config' do
      expect(node).to receive(:config).with('interface Vlan1')
      expect(subject.create('Vlan1')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes the interface in the config' do
      expect(node).to receive(:config).with('no interface Vlan1')
      expect(subject.delete('Vlan1')).to be_truthy
    end
  end

  describe '#default' do
    it 'defaults the interface config' do
      expect(node).to receive(:config).with('default interface Vlan1')
      expect(subject.default('Vlan1')).to be_truthy
    end
  end

  describe '#set_autostate' do
    it 'sets the autostate' do
      commands = ['interface Vlan1', 'autostate']
      opts = { value: :true }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_autostate('Vlan1', opts)).to be_truthy
    end
  end
end
