require 'spec_helper'

require 'rbeapi/api/interfaces'

include FixtureHelpers

describe Rbeapi::Api::BaseInterface do
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
    let(:resource) { subject.get('Loopback0') }

    let(:keys) do
      [:type, :shutdown, :description, :name]
    end

    it 'returns an ethernet resource as a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'returns an interface type of generic' do
      expect(resource[:type]).to eq('generic')
    end

    it 'has all keys' do
      expect(resource.keys).to match_array(keys)
    end
  end

  describe '#create' do
    it 'creates the interface in the config' do
      expect(node).to receive(:config).with('interface Loopback0')
      expect(subject.create('Loopback0')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes the interface in the config' do
      expect(node).to receive(:config).with('no interface Loopback0')
      expect(subject.delete('Loopback0')).to be_truthy
    end
  end

  describe '#default' do
    it 'defaults the interface config' do
      expect(node).to receive(:config).with('default interface Loopback0')
      expect(subject.default('Loopback0')).to be_truthy
    end
  end

  describe '#set_description' do
    it 'sets the interface description' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'description test string'])
      expect(subject.set_description('Loopback0', value: 'test string'))
        .to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'no description'])
      expect(subject.set_description('Loopback0')).to be_truthy
    end

    it 'defaults the interface description' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'default description'])
      expect(subject.set_description('Loopback0', default: true)).to be_truthy
    end

    it 'default is preferred over value' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'default description'])
      expect(subject.set_description('Loopback0', value: 'test',
                                                  default: true)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enables the interface' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'no shutdown'])
      expect(subject.set_shutdown('Loopback0', value: false)).to be_truthy
    end

    it 'disables the interface' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'shutdown'])
      expect(subject.set_shutdown('Loopback0', value: true)).to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'no shutdown'])
      expect(subject.set_shutdown('Loopback0')).to be_truthy
    end

    it 'defaults the interface state' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'default shutdown'])
      expect(subject.set_shutdown('Loopback0', default: true)).to be_truthy
    end

    it 'default is preferred over value' do
      expect(node).to receive(:config).with(['interface Loopback0',
                                             'default shutdown'])
      expect(subject.set_shutdown('Loopback0', value: 'test',
                                               default: true)).to be_truthy
    end
  end
end
