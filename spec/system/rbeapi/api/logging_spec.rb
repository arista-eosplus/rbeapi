require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/logging'

describe Rbeapi::Api::Logging do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:resource) { subject.get }

    it 'contains the enable key' do
      expect(resource).to include(:enable)
    end

    it 'contains the host key' do
      expect(resource).to include(:hosts)
    end

    it 'returns hosts as an Array' do
      expect(resource[:hosts]).to be_a_kind_of(Array)
    end
  end

  describe '#set_enable' do
    it 'configures global logging enabled' do
      node.config('no logging on')
      expect(subject.get[:enable]).to be_falsy
      expect(subject.set_enable(value: true)).to be_truthy
      expect(subject.get[:enable]).to be_truthy
    end

    it 'configures global logging disabled' do
      node.config('logging on')
      expect(subject.get[:enable]).to be_truthy
      expect(subject.set_enable(value: false)).to be_truthy
      expect(subject.get[:enable]).to be_falsy
    end
  end

  describe '#add_host' do
    before { node.config('no logging host foo') }

    it 'adds the host to the list of logging hosts' do
      expect(subject.get[:hosts]).not_to include('foo')
      expect(subject.add_host('foo')).to be_truthy
      expect(subject.get[:hosts]).to include('foo')
    end
  end

  describe '#remove_host' do
    before { node.config('logging host foo') }

    it 'adds the host to the list of logging hosts' do
      expect(subject.get[:hosts]).to include('foo')
      expect(subject.remove_host('foo')).to be_truthy
      expect(subject.get[:hosts]).not_to include('foo')
    end
  end
end
