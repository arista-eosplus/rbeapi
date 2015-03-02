require 'spec_helper'

require 'rbeapi/api/interfaces'

include FixtureHelpers

describe Rbeapi::Api::VxlanInterface do
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
    let(:resource) { subject.get('Vxlan1') }

    let(:keys) do
      [ :type, :shutdown, :description, :name, :source_interface,
        :multicast_group ]
    end

    it 'returns an ethernet resource as a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'returns an interface type of vxlan' do
      expect(resource[:type]).to eq('vxlan')
    end

    it 'has all keys' do
      expect(resource.keys).to match_array(keys)
    end
  end

  describe '#create' do
    it 'creates the interface in the config' do
      expect(node).to receive(:config).with('interface Vxlan1')
      expect(subject.create('Vxlan1')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes the interface in the config' do
      expect(node).to receive(:config).with('no interface Vxlan1')
      expect(subject.delete('Vxlan1')).to be_truthy
    end
  end

  describe '#default' do
    it 'defaults the interface config' do
      expect(node).to receive(:config).with('default interface Vxlan1')
      expect(subject.default('Vxlan1')).to be_truthy
    end
  end

  describe '#set_source_interface' do
    it 'sets the vxlan source interface' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'vxlan source-interface Loopback0'])
      expect(subject.set_source_interface('Vxlan1', value: 'Loopback0')).to be_truthy
    end

    it 'negates the vxlan source interface value' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'no vxlan source-interface'])
      expect(subject.set_source_interface('Vxlan1')).to be_truthy
    end


  describe '#set_description' do
    it 'sets the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'description test string'])
      expect(subject.set_description('Vxlan1', value: 'test string')).to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'no description'])
      expect(subject.set_description('Vxlan1')).to be_truthy
    end

    it 'defaults the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'default description'])
      expect(subject.set_description('Vxlan1', default: true)).to be_truthy
    end

    it 'default is preferred over value' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'default description'])
      expect(subject.set_description('Vxlan1', value: 'test', default: true)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enables the interface' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'no shutdown'])
      expect(subject.set_shutdown('Vxlan1', value: false)).to be_truthy
    end

    it 'disables the interface' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'shutdown'])
      expect(subject.set_shutdown('Vxlan1', value: true)).to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'no shutdown'])
      expect(subject.set_shutdown('Vxlan1')).to be_truthy
    end

    it 'defaults the interface state' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'default shutdown'])
      expect(subject.set_shutdown('Vxlan1', default: true)).to be_truthy
    end

    it 'default is preferred over value' do
      expect(node).to receive(:config).with(['interface Vxlan1', 'default shutdown'])
      expect(subject.set_shutdown('Vxlan1', value: 'test', default: true)).to be_truthy
    end
  end


end

