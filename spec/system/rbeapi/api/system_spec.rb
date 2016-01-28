require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/system'

describe Rbeapi::Api::System do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { hostname: 'localhost', iprouting: true, banner_motd: '',
        banner_login: '' }
    end

    before do
      node.config(['hostname localhost', 'ip routing', 'no banner motd',
                   'no banner login'])
    end

    it 'returns the snmp resource' do
      expect(subject.get).to eq(entity)
    end
  end

  describe '#set_hostname' do
    before { node.config(['hostname localhost']) }

    it 'configures the system hostname value' do
      expect(subject.get[:hostname]).to eq('localhost')
      expect(subject.set_hostname(value: 'foo')).to be_truthy
      expect(subject.get[:hostname]).to eq('foo')
    end

    it 'configures the system hostname with a dot value' do
      expect(subject.get[:hostname]).to eq('localhost')
      expect(subject.set_hostname(value: 'foo.bar')).to be_truthy
      expect(subject.get[:hostname]).to eq('foo.bar')
    end

    it 'negates the hostname' do
      expect(subject.set_hostname(enable: false)).to be_truthy
      expect(subject.get[:hostname]).to be_empty
    end

    it 'defaults the hostname' do
      expect(subject.set_hostname(default: true)).to be_truthy
      expect(subject.get[:hostname]).to be_empty
    end

    it 'configures the system hostname value' do
      expect(subject.get[:iprouting]).to eq(true)
      expect(subject.set_iprouting(enable: true)).to be_truthy
      expect(subject.get[:iprouting]).to eq(true)
    end
  end

  describe '#set_iprouting' do
    describe 'negates ip routing' do
      before { node.config(['ip routing']) }

      it 'negates ip routing' do
        expect(subject.get[:iprouting]).to eq(true)
        expect(subject.set_iprouting(enable: false)).to be_truthy
        expect(subject.get[:iprouting]).to eq(false)
      end

      it 'defaults ip routing' do
        expect(subject.get[:iprouting]).to eq(true)
        expect(subject.set_iprouting(default: true)).to be_truthy
        expect(subject.get[:iprouting]).to eq(false)
      end
    end

    describe 'enables ip routing' do
      before { node.config(['no ip routing']) }

      it 'negates ip routing' do
        expect(subject.get[:iprouting]).to eq(false)
        expect(subject.set_iprouting(enable: true)).to be_truthy
        expect(subject.get[:iprouting]).to eq(true)
      end

      it 'defaults ip routing' do
        expect(subject.get[:iprouting]).to eq(false)
        expect(subject.set_iprouting(default: false)).to be_truthy
        expect(subject.get[:iprouting]).to eq(true)
      end
    end
  end

  describe '#set_banner' do
    before { node.config(['no banner login', 'no banner motd']) }

    it 'configures the login value' do
      expect(subject.get[:banner_login]).to eq('')
      expect(subject.set_banner('login', value: 'foo')).to be_truthy
      expect(subject.get[:banner_login]).to eq('foo')
    end

    it 'negates the login value' do
      expect(subject.get[:banner_login]).to eq('')
      expect(subject.set_banner('login', enable: false)).to be_truthy
      expect(subject.get[:banner_login]).to eq('')
    end

    it 'defaults the login value' do
      expect(subject.get[:banner_login]).to eq('')
      expect(subject.set_banner('login', default: true)).to be_truthy
      expect(subject.get[:banner_login]).to eq('')
    end

    it 'configures the motd value' do
      expect(subject.get[:banner_motd]).to eq('')
      expect(subject.set_banner('motd', value: 'foo')).to be_truthy
      expect(subject.get[:banner_motd]).to eq('foo')
    end

    it 'negates the motd value' do
      expect(subject.get[:banner_motd]).to eq('')
      expect(subject.set_banner('motd', enable: false)).to be_truthy
      expect(subject.get[:banner_motd]).to eq('')
    end

    it 'defaults the motd value' do
      expect(subject.get[:banner_motd]).to eq('')
      expect(subject.set_banner('motd', default: true)).to be_truthy
      expect(subject.get[:banner_motd]).to eq('')
    end
  end
end
