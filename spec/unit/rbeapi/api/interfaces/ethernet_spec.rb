require 'spec_helper'

require 'rbeapi/api/interfaces'

include FixtureHelpers

describe Rbeapi::Api::EthernetInterface do
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
    let(:resource) { subject.get('Ethernet1') }

    let(:keys) do
      [:type, :speed, :sflow, :flowcontrol_send, :flowcontrol_receive,
       :shutdown, :description, :encapsulation, :name, :load_interval, :lacp_priority]
    end

    it 'returns an ethernet resource as a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'returns an interface type of ethernet' do
      expect(resource[:type]).to eq('ethernet')
    end

    it 'has all keys' do
      expect(resource.keys).to match_array(keys)
    end
  end

  describe '#create' do
    it 'raises a NotImplementedError on create' do
      expect { subject.create('Ethernet1') }.to raise_error(NotImplementedError)
    end
  end

  describe '#delete' do
    it 'raises a NotImplementedError on delete' do
      expect { subject.delete('Ethernet1') }.to raise_error(NotImplementedError)
    end
  end

  describe '#default' do
    it 'defaults the interface config' do
      expect(node).to receive(:config).with('default interface Ethernet1')
      expect(subject.default('Ethernet1')).to be_truthy
    end
  end

  describe '#set_description' do
    it 'sets the interface description' do
      expect(node).to receive(:config).with(['interface Ethernet1',
                                             'description test string'])
      expect(subject.set_description('Ethernet1', value: 'test string'))
        .to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Ethernet1',
                                             'no description'])
      expect(subject.set_description('Ethernet1', enable: false)).to be_truthy
    end

    it 'defaults the interface description' do
      expect(node).to receive(:config).with(['interface Ethernet1',
                                             'default description'])
      expect(subject.set_description('Ethernet1', default: true)).to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config).with(['interface Ethernet1',
                                             'default description'])
      expect(subject.set_description('Ethernet1', enable: false,
                                                  default: true)).to be_truthy
    end
  end

  describe '#set_encapsulation' do
    it 'sets the interface encapsulation' do
      expect(node).to receive(:config).with(['interface Ethernet1.1',
                                             'encapsulation dot1q vlan 10'])
      expect(subject.set_encapsulation('Ethernet1.1', value: '10'))
        .to be_truthy
    end

    it 'negates the interface encapsulation' do
      expect(node).to receive(:config).with(['interface Ethernet1.1',
                                             'no encapsulation dot1q vlan'])
      expect(subject.set_encapsulation('Ethernet1.1', enable: false)).to be_truthy
    end

    it 'defaults the interface encapsulation' do
      expect(node).to receive(:config).with(['interface Ethernet1.1',
                                             'default encapsulation dot1q vlan'])
      expect(subject.set_encapsulation('Ethernet1.1', default: true)).to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config).with(['interface Ethernet1.1',
                                             'default encapsulation dot1q vlan'])
      expect(subject.set_encapsulation('Ethernet1.1', enable: false,
                                                      default: true)).to be_truthy
    end
  end
end
