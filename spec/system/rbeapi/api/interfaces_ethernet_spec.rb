
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
      { name: 'Ethernet1', type: 'ethernet', description: '', shutdown: false,
        speed: 'auto', forced: false, sflow: true, flowcontrol_send: 'off',
        flowcontrol_receive: 'off' }
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

  describe '#delete' do
    it 'raises an error on create' do
      expect { subject.create('Ethernet1') }.to raise_error(NotImplementedError)
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

    it 'sets default true' do
      expect(subject.set_speed('Ethernet1', default: true)).to be_truthy
    end

    it 'sets enable true' do
      expect(subject.set_speed('Ethernet1', default: false,
                                            enable: true)).to be_falsy
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
end
