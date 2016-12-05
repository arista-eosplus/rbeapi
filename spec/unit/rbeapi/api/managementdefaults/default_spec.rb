require 'spec_helper'

require 'rbeapi/api/managementdefaults'

include FixtureHelpers

describe Rbeapi::Api::Managementdefaults do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def managementdefaults
    managementdefaults = Fixtures[:managementdefaults]
    return managementdefaults if managementdefaults
    fixture('managementdefaults', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config)
      .and_return(managementdefaults)
  end

  describe '#get' do
    let(:keys) { [:secret_hash] }

    it 'returns the management defaults resource hash with all keys' do
      expect(subject.get.keys).to match_array(keys)
    end
  end

  describe '#set_secret_hash' do
    it 'sets the secret_hash to sha512' do
      expect(node).to receive(:config).with(['management defaults',
                                             'secret hash sha512'])
      expect(subject.set_secret_hash(value: 'sha512')).to be_truthy
    end

    it 'sets the secret_hash to md5' do
      expect(node).to receive(:config).with(['management defaults',
                                             'secret hash md5'])
      expect(subject.set_secret_hash(value: 'md5')).to be_truthy
    end

    it 'defaults the secret_hash' do
      expect(node).to receive(:config).with(['management defaults',
                                             'secret hash '])
      expect(subject.set_secret_hash(default: true)).to be_truthy
    end
  end
end
