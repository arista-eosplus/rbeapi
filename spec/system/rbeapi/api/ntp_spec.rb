require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/ntp'

describe Rbeapi::Api::Ntp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:resource) { subject.get }

    it 'contains the source_interface key' do
      expect(resource).to include(:source_interface)
    end

    it 'contains the servers key' do
      expect(resource).to include(:servers)
    end

    it 'returns servers as an Hash' do
      expect(resource[:servers]).to be_a_kind_of(Hash)
    end
  end

  describe '#set_source_interface' do
    before { node.config('no ntp source') }

    it 'sets the ntp source interface value' do
      expect(subject.get[:source_interface]).to be_empty
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
    end

    it 'negates the ntp source interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(enable: false)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end

    it 'defaults the ntp source interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(default: true)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end
  end

  describe '#add_server' do
    before { node.config('no ntp server foo') }

    it 'adds the host to the list of servers' do
      expect(subject.get[:servers]).not_to include('foo')
      expect(subject.add_server('foo')).to be_truthy
      expect(subject.get[:servers]).to include('foo')
    end
  end

  describe '#remove_server' do
    before { node.config('ntp server foo') }

    it 'adds the server to the list of ntp servers' do
      expect(subject.get[:servers]).to include('foo')
      expect(subject.remove_server('foo')).to be_truthy
      expect(subject.get[:servers]).not_to include('foo')
    end
  end

  describe '#set_prefer' do
    it 'configures the ntp server with the prefer keyword' do
      node.config('no ntp server foo')
      expect(subject.get[:servers]).not_to include('foo')
      expect(subject.set_prefer('foo', true)).to be_truthy
      expect(subject.get[:servers]).to include('foo')
      expect(subject.get[:servers]['foo'][:prefer]).to be_truthy
    end

    it 'unconfigures the prefer value' do
      node.config('ntp server foo prefer')
      expect(subject.get[:servers]['foo'][:prefer]).to be_truthy
      expect(subject.set_prefer('foo', false)).to be_truthy
      expect(subject.get[:servers]['foo'][:prefer]).to be_falsy
    end
  end
end
