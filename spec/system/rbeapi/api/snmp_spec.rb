require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/snmp'

describe Rbeapi::Api::Snmp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:keys) do
      [:location, :contact, :chassis_id, :source_interface]
    end

    it 'has the required key in the resource hash' do
      keys.each do |key|
        expect(subject.get).to include(key)
      end
    end
  end

  describe '#set_location' do
    before { node.config(['no snmp-server location']) }

    it 'configures the snmp location value' do
      expect(subject.get[:location]).to be_empty
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
    end
  end

  describe '#set_contact' do
    before { node.config('no snmp-server contact') }

    it 'configures the snmp contact value' do
      expect(subject.get[:contact]).to be_empty
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
    end
  end

  describe '#set_chassis_id' do
    before { node.config('no snmp-server chassis-id') }

    it 'configures the snmp chassis-id value' do
      expect(subject.get[:chassis_id]).to be_empty
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
    end
  end

  describe '#set_source_interface' do
    before { node.config('no snmp-server source-interface') }

    it 'configures the snmp source-interface value' do
      expect(subject.get[:source_interface]).to be_empty
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
    end
  end
end
