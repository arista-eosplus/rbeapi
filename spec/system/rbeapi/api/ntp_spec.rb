require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/ntp'

describe Rbeapi::Api::Ntp do
  subject { described_class.new(@node) }

  before(:all) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    @node = Rbeapi::Client.connect_to('dut')

    @node.config(['no ntp authenticate',
                  'default ntp trusted-key',
                  'no ntp server foo',
                  'no ntp server vrf rspec bar',
                  'vrf definition rspec'])
  end

  describe '#get' do
    let(:resource) { subject.get }

    it 'contains the auth_keys key' do
      expect(resource).to include(:auth_keys)
    end

    it 'returns servers as an Hash' do
      expect(resource[:auth_keys]).to be_a_kind_of(Hash)
    end

    it 'contains the source_interface key' do
      expect(resource).to include(:source_interface)
    end

    it 'contains the authenticate key' do
      expect(resource).to include(:authenticate)
    end

    it 'returns authenticate as Boolean' do
      expect(resource[:auth_keys]).to be_a_kind_of(Hash)
    end

    it 'contains the servers key' do
      expect(resource).to include(:servers)
    end

    it 'returns servers as an Hash' do
      expect(resource[:servers]).to be_a_kind_of(Hash)
    end
  end

  describe '#set_ntp_authenticate' do
    it 'sets ntp authenticate value' do
      expect(subject.get[:authenticate]).to be_falsy
      expect(subject.set_authenticate(enable: true)).to be_truthy
      expect(subject.get[:authenticate]).to be_truthy
    end

    it 'negates ntp authenticate' do
      expect(subject.get[:authenticate]).to be_truthy
      expect(subject.set_authenticate(enable: false)).to be_truthy
      expect(subject.get[:authenticate]).to be_falsy
    end

    it 'defaults ntp authenticate' do
      @node.config('ntp authenticate')
      expect(subject.get[:authenticate]).to be_truthy
      expect(subject.set_authenticate(default: true)).to be_truthy
      expect(subject.get[:authenticate]).to be_falsy
    end
  end

  describe '#set_source_interface' do
    before { @node.config('no ntp source') }

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

  describe '#add_basic_server' do
    before { @node.config('no ntp server foo') }

    it 'adds the host to the list of servers' do
      expect(subject.get[:servers]).not_to include('foo')
      expect(subject.add_server('foo')).to be_truthy
      expect(subject.get[:servers]).to include('foo')
    end
  end

  describe '#remove_basic_server' do
    before { @node.config('ntp server foo') }

    it 'removes the server from the list of ntp servers' do
      expect(subject.get[:servers]).to include('foo')
      expect(subject.remove_server('foo')).to be_truthy
      expect(subject.get[:servers]).not_to include('foo')
    end
  end

  describe '#set_prefer' do
    it 'configures the ntp server with the prefer keyword' do
      @node.config('no ntp server foo')
      expect(subject.get[:servers]).not_to include('foo')
      expect(subject.set_prefer('foo', true)).to be_truthy
      expect(subject.get[:servers]).to include('foo')
      expect(subject.get[:servers]['foo'][:prefer]).to be_truthy
    end

    it 'unconfigures the prefer value' do
      @node.config('ntp server foo prefer')
      expect(subject.get[:servers]['foo'][:prefer]).to be_truthy
      expect(subject.set_prefer('foo', false)).to be_truthy
      expect(subject.get[:servers]['foo'][:prefer]).to be_falsy
    end
  end

  describe '#add_nondefault_server' do
    before { @node.config('no ntp server foo') }

    let(:opts) do
      { vrf: 'rspec',
        prefer: true,
        minpoll: 5,
        maxpoll: 12,
        source_interface: 'Loopback0',
        key: 1 }
    end

    it 'adds the host to the list of servers' do
      expect(subject.get[:servers]).not_to include('bar')
      expect(subject.add_server('bar', false, opts)).to be_truthy
      expect(subject.get[:servers]).to include('bar')
      expect(subject.get[:servers]['bar']).to eq(opts)
    end
  end

  describe '#remove_nondefault_server' do
    it 'removes the server from the list of ntp servers' do
      expect(subject.get[:servers]).to include('bar')
      expect(subject.remove_server('bar', 'rspec')).to be_truthy
      expect(subject.get[:servers]).not_to include('bar')
    end
  end

  describe '#set_ntp_trusted_keys' do
    it 'adds key to the list of trusted-keys' do
      expect(subject.set_trusted_key(value: 1)).to be_truthy
      expect(subject.get[:trusted_key]).to eq('1')
      expect(subject.set_trusted_key(value: 5)).to be_truthy
      expect(subject.get[:trusted_key]).to eq('5')
    end

    it 'changes key in the list of trusted-keys' do
      expect(subject.set_trusted_key(value: 5)).to be_truthy
      expect(subject.get[:trusted_key]).to eq('5')
    end
  end

  describe '#remove_ntp_trusted_keys' do
    it 'removes key in the list of trusted-keys' do
      expect(subject.set_trusted_key(enable: false, value: 5)).to be_truthy
      expect(subject.get[:trusted_key]).to eq('')
    end
  end

  describe '#set_ntp_authentication_key' do
    let(:opts) do
      { algorithm: 'md5',
        key: 1,
        mode: 7,
        password: '06120A3258' }
    end

    it 'adds authentication-key key' do
      expect(subject.set_authentication_key(opts)).to be_truthy
      expect(subject.get[:auth_keys]).to include('1')
      expect(subject.get[:auth_keys]['1'][:algorithm]).to eq('md5')
      expect(subject.get[:auth_keys]['1'][:mode]).to eq('7')
      expect(subject.get[:auth_keys]['1'][:password]).to eq('06120A3258')
    end
  end

  describe '#remove_ntp_authentication_key' do
    let(:opts) do
      { algorithm: 'md5',
        key: 1,
        mode: 7,
        password: '06120A3258' }
    end

    let(:disable) do
      { key: 1,
        enable: false }
    end

    let(:default) do
      { key: 1,
        default: true }
    end

    it 'remove authentication-key key via enable' do
      expect(subject.set_authentication_key(opts)).to be_truthy
      expect(subject.get[:auth_keys]).to include('1')
      expect(subject.set_authentication_key(disable)).to be_truthy
      expect(subject.get[:auth_keys]).not_to include('1')
    end

    it 'remove authentication-key key via default' do
      expect(subject.set_authentication_key(opts)).to be_truthy
      expect(subject.get[:auth_keys]).to include('1')
      expect(subject.set_authentication_key(default)).to be_truthy
      expect(subject.get[:auth_keys]).not_to include('1')
    end
  end

  after(:all) do
    @node.config(['no ntp authenticate',
                  'default ntp trusted-key',
                  'no ntp server foo',
                  'no ntp server vrf rspec bar',
                  'vrf definition rspec'])
  end
end
