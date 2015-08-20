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
      [:type, :shutdown, :description, :name, :source_interface,
       :multicast_group, :udp_port, :flood_list, :vlans]
    end

    it 'returns the resource as a hash' do
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
      commands = ['interface Vxlan1', 'vxlan source-interface Loopback0']
      opts = { value: 'Loopback0' }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_source_interface('Vxlan1', opts)).to be_truthy
    end

    it 'negates the vxlan source interface value' do
      commands = ['interface Vxlan1', 'no vxlan source-interface']
      expect(node).to receive(:config).with(commands)
      expect(subject.set_source_interface('Vxlan1', enable: false)).to be_truthy
    end

    it 'defaults the source interface setting' do
      commands = ['interface Vxlan1', 'default vxlan source-interface']
      opts = { default: true }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_source_interface('Vxlan1', opts)).to be_truthy
    end

    it 'prefers default over enable' do
      commands = ['interface Vxlan1', 'default vxlan source-interface']
      opts = { default: true, enable: false }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_source_interface('Vxlan1', opts)).to be_truthy
    end
  end

  describe '#set_multicast_group' do
    it 'sets the vxlan multicast group' do
      commands = ['interface Vxlan1', 'vxlan multicast-group 239.10.10.10']
      opts = { value: '239.10.10.10' }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_multicast_group('Vxlan1', opts)).to be_truthy
    end

    it 'negates the vxlan multicast group value' do
      commands = ['interface Vxlan1', 'no vxlan multicast-group']
      expect(node).to receive(:config).with(commands)
      expect(subject.set_multicast_group('Vxlan1', enable: false)).to be_truthy
    end

    it 'defaults the multicast group setting' do
      commands = ['interface Vxlan1', 'default vxlan multicast-group']
      opts = { default: true }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_multicast_group('Vxlan1', opts)).to be_truthy
    end

    it 'prefers default over value' do
      commands = ['interface Vxlan1', 'default vxlan multicast-group']
      opts = { default: true, enable: false }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_multicast_group('Vxlan1', opts)).to be_truthy
    end
  end

  describe '#set_udp_port' do
    it 'sets the vxlan udp-port' do
      commands = ['interface Vxlan1', 'vxlan udp-port 1024']
      opts = { value: '1024' }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_udp_port('Vxlan1', opts)).to be_truthy
    end

    it 'negates the vxlan udp-port value' do
      commands = ['interface Vxlan1', 'no vxlan udp-port']
      expect(node).to receive(:config).with(commands)
      expect(subject.set_udp_port('Vxlan1', enable: false)).to be_truthy
    end

    it 'defaults the vxlan udp-port setting' do
      commands = ['interface Vxlan1', 'default vxlan udp-port']
      opts = { default: true }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_udp_port('Vxlan1', opts)).to be_truthy
    end

    it 'prefers default over enable' do
      commands = ['interface Vxlan1', 'default vxlan udp-port']
      opts = { default: true, enable: false }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_udp_port('Vxlan1', opts)).to be_truthy
    end
  end

  describe '#add_vtep' do
    it 'adds value to the flood list' do
      commands = ['interface Vxlan1', 'vxlan flood vtep add 1.1.1.1']
      expect(node).to receive(:config).with(commands)
      expect(subject.add_vtep('Vxlan1', '1.1.1.1')).to be_truthy
    end
  end

  describe '#remove_vtep' do
    it 'removes value from the flood list' do
      commands = ['interface Vxlan1', 'vxlan flood vtep remove 1.1.1.1']
      expect(node).to receive(:config).with(commands)
      expect(subject.remove_vtep('Vxlan1', '1.1.1.1')).to be_truthy
    end
  end

  describe '#update_vlan' do
    it 'updates the vlan to vni mapping' do
      commands = ['interface Vxlan1', 'vxlan vlan 10 vni 10']
      expect(node).to receive(:config).with(commands)
      expect(subject.update_vlan('Vxlan1', 10, 10)).to be_truthy
    end
  end

  describe '#remove_vlan' do
    it 'removes the vlan to vni mapping' do
      commands = ['interface Vxlan1', 'no vxlan vlan 10 vni']
      expect(node).to receive(:config).with(commands)
      expect(subject.remove_vlan('Vxlan1', 10)).to be_truthy
    end
  end

  describe '#set_description' do
    it 'sets the interface description' do
      commands = ['interface Vxlan1', 'description test string']
      opts = { value: 'test string' }
      expect(node).to receive(:config).with(commands)
      expect(subject.set_description('Vxlan1', opts)).to be_truthy
    end

    it 'negates the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'no description'])
      expect(subject.set_description('Vxlan1', enable: false)).to be_truthy
    end

    it 'defaults the interface description' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'default description'])
      expect(subject.set_description('Vxlan1', default: true)).to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'default description'])
      expect(subject.set_description('Vxlan1', enable: false,
                                               default: true)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enables the interface' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'no shutdown'])
      expect(subject.set_shutdown('Vxlan1', enable: true)).to be_truthy
    end

    it 'disables the interface' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'shutdown'])
      expect(subject.set_shutdown('Vxlan1', enable: false)).to be_truthy
    end

    it 'defaults the interface state' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'default shutdown'])
      expect(subject.set_shutdown('Vxlan1', default: true)).to be_truthy
    end

    it 'default is preferred over enable' do
      expect(node).to receive(:config).with(['interface Vxlan1',
                                             'default shutdown'])
      expect(subject.set_shutdown('Vxlan1', enable: false, default: true))
        .to be_truthy
    end
  end
end
