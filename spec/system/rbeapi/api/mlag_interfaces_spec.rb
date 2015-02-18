require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/mlag'

describe Rbeapi::Api::MlagInterfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do

    let(:entity) do
      { mlag_id: '1' }
    end

    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'returns the mlag interface resource' do
      expect(subject.get('Port-Channel1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Port-Channel1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
 end

  describe '#create' do
    before { node.config(['interface Port-Channel1', 'no mlag']) }

    it 'creates a new mlag interface resource' do
      expect(subject.get('Port-Channel1')).to be_nil
      expect(subject.create('Port-Channel1', '1')).to be_truthy
      expect(subject.get('Port-Channel1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'deletes a switchport resource' do
      expect(subject.get('Port-Channel1')).not_to be_nil
      expect(subject.delete('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Port-Channel1', 'mlag 1']) }

    it 'sets Port-Channel1 to default' do
      expect(subject.get('Port-Channel1')).not_to be_nil
      expect(subject.default('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')).to be_nil
    end
  end

  describe '#set_mlag_id' do
    before { node.config(['interface Port-Channel1', 'no mlag']) }

    it 'sets Port-Channel1 to default' do
      expect(subject.get('Port-Channel1')).to be_nil
      expect(subject.set_mlag_id('Port-Channel1', value: '1')).to be_truthy
      expect(subject.get('Port-Channel1')[:mlag_id]).to eq('1')
    end
  end

end

