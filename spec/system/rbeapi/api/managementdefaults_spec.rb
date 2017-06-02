require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/managementdefaults'

describe Rbeapi::Api::Managementdefaults do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    before { node.config(['management defaults', 'default secret hash']) }

    it 'contains all required settings' do
      expect(subject.get).to include(:secret_hash)
    end
  end

  describe '#set_secret_hash' do
    before { node.config(['management defaults', 'default secret hash']) }

    it 'configures the management defaults secret hash value' do
      expect(subject.set_secret_hash(value: 'md5')).to be_truthy
      expect(subject.get[:secret_hash]).to eq('md5')
      expect(subject.set_secret_hash(value: 'sha512')).to be_truthy
      expect(subject.get[:secret_hash]).to eq('sha512')
    end
  end
end
