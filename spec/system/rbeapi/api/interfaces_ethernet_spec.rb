
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
      { name: 'Ethernet1', type: 'ethernet', description: '', encapsulation: '',
        shutdown: false, load_interval: '', speed: 'default', sflow: true,
        flowcontrol_send: 'off', flowcontrol_receive: 'off',
        lacp_priority: '32768' }
    end

    before { node.config(['default interface Ethernet1']) }

    it 'returns the interface resource' do
      expect(subject.get('Ethernet1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['default interface Ethernet1']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Ethernet1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#create' do
    it 'raises an error on create' do
      expect { subject.create('Ethernet1') }.to raise_error(NotImplementedError)
    end
  end

  describe '#create' do
    before { node.config('no interface Ethernet1.1') }

    it 'creates a new ethernet subinterface' do
      expect(subject.get('Ethernet1.1')).to be_nil
      expect(subject.create('Ethernet1.1')).to be_truthy
      expect(subject.get('Ethernet1.1')).not_to be_nil
      node.config(['no interface Ethernet1.1'])
    end
  end

  describe '#delete' do
    it 'raises an error on create' do
      expect { subject.create('Ethernet1') }.to raise_error(NotImplementedError)
    end
  end

  describe '#delete' do
    before { node.config(['interface Ethernet1.1']) }

    it 'deletes an ethernet subinterface resource' do
      expect(subject.get('Ethernet1.1')).not_to be_nil
      expect(subject.delete('Ethernet1.1')).to be_truthy
      expect(subject.get('Ethernet1.1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Ethernet1', :shutdown]) }

    it 'sets Ethernet1 to default' do
      expect(subject.get('Ethernet1')[:shutdown]).to be_truthy
      expect(subject.default('Ethernet1')).to be_truthy
      expect(subject.get('Ethernet1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_description' do
    it 'sets the description value on the interface' do
      node.config(['interface Ethernet1', 'no description'])
      expect(subject.get('Ethernet1')[:description]).to be_empty
      expect(subject.set_description('Ethernet1', value: 'foo bar'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:description]).to eq('foo bar')
    end
  end

  describe '#set_encapsulation' do
    it 'sets the encapsulation value on the interface' do
      node.config(['interface Ethernet1.1', 'no encapsulation dot1q vlan'])
      expect(subject.get('Ethernet1.1')[:encapsulation]).to be_empty
      expect(subject.set_encapsulation('Ethernet1.1', value: '10'))
        .to be_truthy
      expect(subject.get('Ethernet1.1')[:encapsulation]).to eq('10')
      node.config(['no interface Ethernet1.1'])
    end
  end

  describe '#set_shutdown' do
    it 'shutdown the interface' do
      node.config(['interface Ethernet1', 'no shutdown'])
      expect(subject.get('Ethernet1')[:shutdown]).to be_falsy
      expect(subject.set_shutdown('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:shutdown]).to be_truthy
    end

    it 'enable the interface' do
      node.config(['interface Ethernet1', :shutdown])
      expect(subject.get('Ethernet1')[:shutdown]).to be_truthy
      expect(subject.set_shutdown('Ethernet1', enable: true)).to be_truthy
      expect(subject.get('Ethernet1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_speed' do
    before { node.config(['default interface Ethernet1']) }

    it 'sets enable true' do
      expect(subject.set_speed('Ethernet1', default: false,
                                            enable: true)).to include(false)
    end
  end

  describe '#set_sflow' do
    it 'sets the sflow value to true' do
      node.config(['interface Ethernet1', 'no sflow enable'])
      expect(subject.get('Ethernet1')[:sflow]).to be_falsy
      expect(subject.set_sflow('Ethernet1', enable: true)).to be_truthy
      expect(subject.get('Ethernet1')[:sflow]).to be_truthy
    end

    it 'sets the sflow value to false' do
      node.config(['interface Ethernet1', 'sflow enable'])
      expect(subject.get('Ethernet1')[:sflow]).to be_truthy
      expect(subject.set_sflow('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:sflow]).to be_falsy
    end
  end

  describe '#set_flowcontrol_send' do
    it 'sets the flowcontrol send value to on' do
      node.config(['interface Ethernet1', 'flowcontrol send off'])
      expect(subject.get('Ethernet1')[:flowcontrol_send]).to eq('off')
      expect(subject.set_flowcontrol_send('Ethernet1', value: 'on'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:flowcontrol_send]).to eq('on')
    end

    it 'sets the flowcontrol send value to off' do
      node.config(['interface Ethernet1', 'flowcontrol send on'])
      expect(subject.get('Ethernet1')[:flowcontrol_send]).to eq('on')
      expect(subject.set_flowcontrol_send('Ethernet1', value: 'off'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:flowcontrol_send]).to eq('off')
    end
  end

  describe '#set_flowcontrol_receive' do
    it 'sets the flowcontrol receive value to on' do
      node.config(['interface Ethernet1', 'flowcontrol receive off '])
      expect(subject.get('Ethernet1')[:flowcontrol_receive]).to eq('off')
      expect(subject.set_flowcontrol_receive('Ethernet1', value: 'on'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:flowcontrol_receive]).to eq('on')
    end

    it 'sets the flowcontrol receive value to off' do
      node.config(['interface Ethernet1', 'flowcontrol receive on'])
      expect(subject.get('Ethernet1')[:flowcontrol_receive]).to eq('on')
      expect(subject.set_flowcontrol_receive('Ethernet1', value: 'off'))
        .to be_truthy
      expect(subject.get('Ethernet1')[:flowcontrol_receive]).to eq('off')
    end
  end

  describe '#set_load_interval' do
    before do
      node.config(['interface Ethernet1', 'default load-interval'])
    end

    it 'sets the load-interval value on the interface' do
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
      expect(subject.set_load_interval('Ethernet1', value: '10')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('10')
    end

    it 'negates the load-interval' do
      expect(subject.set_load_interval('Ethernet1', value: '20')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('20')
      expect(subject.set_load_interval('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
    end

    it 'defaults the load-interval' do
      expect(subject.set_load_interval('Ethernet1', value: '10')).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('10')
      expect(subject.set_load_interval('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:load_interval]).to eq('')
    end
  end

  describe '#set_lacp_priority' do
    before do
      node.config(['interface Ethernet1', 'default lacp port-priority'])
    end

    it 'sets the lacp port-priority value on the interface' do
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('32768')
      expect(subject.set_lacp_priority('Ethernet1', value: '0')).to be_truthy
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('0')
    end

    it 'negates the lacp port-priority' do
      expect(subject.set_lacp_priority('Ethernet1', value: '1')).to be_truthy
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('1')
      expect(subject.set_lacp_priority('Ethernet1', enable: false)).to be_truthy
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('32768')
    end

    it 'defaults the lacp port-priority' do
      expect(subject.set_lacp_priority('Ethernet1', value: '2')).to be_truthy
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('2')
      expect(subject.set_lacp_priority('Ethernet1', default: true)).to be_truthy
      expect(subject.get('Ethernet1')[:lacp_priority]).to eq('32768')
    end
  end
end
