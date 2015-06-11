require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/mlag'

describe Rbeapi::Api::Mlag do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { mlag_id: 1 }
    end

    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'returns the mlag interface resource' do
      expect(subject.get[:interfaces]['Port-Channel1']).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'returns the interface collection' do
      expect(subject.get[:interfaces]).to include('Port-Channel1')
    end

    it 'returns a hash collection' do
      expect(subject.get[:interfaces]).to be_a_kind_of(Hash)
    end
  end

  describe '#set_mlag_id' do
    before { node.config(['interface Port-Channel1', 'no mlag']) }

    it 'sets mlag_id on Port-Channel1' do
      expect(subject.get[:interfaces]['Port-Channel1']).to be_nil
      expect(subject.set_mlag_id('Port-Channel1', value: '1')).to be_truthy
      expect(subject.get[:interfaces]['Port-Channel1'][:mlag_id]).to eq(1)
    end
  end

  describe '#set_mlag_id default' do
    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'sets Port-Channel1 to default' do
      expect(subject.get[:interfaces]['Port-Channel1']).not_to be_nil
      expect(subject.set_mlag_id('Port-Channel1', default: true)).to be_truthy
      expect(subject.get[:interfaces]['Port-Channel1']).to be_nil
    end
  end
end
