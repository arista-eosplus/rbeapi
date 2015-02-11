require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/system'

describe Rbeapi::Api::System do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('veos02') }

  describe '#get' do

    let(:entity) do
      { 'hostname' => 'localhost' }
    end

    before { node.config('hostname localhost') }

    it 'returns the snmp resource' do
      expect(subject.get).to eq(entity)
    end
  end

  describe '#set_system' do
    before { node.config('hostname localhost') }

    it 'configures the system hostname value' do
      expect(subject.get['hostname']).to eq('localhost')
      expect(subject.set_hostname(value: 'foo')).to be_truthy
      expect(subject.get['hostname']).to eq('foo')
    end
  end
end


