require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/dns'

describe Rbeapi::Api::Dns do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    [:domain_name, :domain_list, :name_servers].each do |key|
      it 'returns the dns resource with key' do
        expect(subject.get).to include(key)
      end
    end
  end

  describe '#set_domain_name' do
    before { node.config(['no ip domain-name']) }

    it 'configure the ip domain-name value' do
      expect(subject.get[:domain_name]).to be_empty
      expect(subject.set_domain_name(value: 'arista.com')).to be_truthy
      expect(subject.get[:domain_name]).to eq('arista.com')
    end

    it 'negates the domain name' do
      expect(subject.set_domain_name(value: 'arista.com')).to be_truthy
      expect(subject.get[:domain_name]).to eq('arista.com')
      expect(subject.set_domain_name(enable: false)).to be_truthy
      expect(subject.get[:domain_name]).to be_empty
    end

    it 'defaults the domain name' do
      expect(subject.set_domain_name(value: 'arista.com')).to be_truthy
      expect(subject.get[:domain_name]).to eq('arista.com')
      expect(subject.set_domain_name(default: true)).to be_truthy
      expect(subject.get[:domain_name]).to be_empty
    end
  end

  describe '#set_name_servers' do
    let(:servers) { %w(1.2.3.4 5.6.7.8 9.10.11.12) }

    before { node.config('no ip name-server') }

    it 'add all the servers to the name servers list' do
      expect(subject.get[:name_servers]).to be_empty
      expect(subject.set_name_servers(value: servers)).to be_truthy
      expect(subject.get[:name_servers]).to eq(servers)
    end

    it 'negate the name servers list' do
      expect(subject.get[:name_servers]).to be_empty
      expect(subject.set_name_servers(enable: false)).to be_truthy
      expect(subject.get[:name_servers]).to be_empty
    end

    it 'default the name servers list' do
      expect(subject.get[:name_servers]).to be_empty
      expect(subject.set_name_servers(default: true)).to be_truthy
      expect(subject.get[:name_servers]).to be_empty
    end
  end

  describe '#add_name_server' do
    before do
      begin
        node.config('no ip name-server 1.2.3.4')
      rescue Rbeapi::Eapilib::CommandError
        next
      end
    end

    it 'adds the name-server to the list' do
      expect(subject.get[:name_servers]).not_to include('1.2.3.4')
      expect(subject.add_name_server('1.2.3.4')).to be_truthy
      expect(subject.get[:name_servers]).to include('1.2.3.4')
    end
  end

  describe '#remove_name_server' do
    before { node.config(['ip name-server 1.2.3.4']) }

    it 'removes the name-server from the list' do
      expect(subject.get[:name_servers]).to include('1.2.3.4')
      expect(subject.remove_name_server('1.2.3.4')).to be_truthy
      expect(subject.get[:name_servers]).not_to include('1.2.3.4')
    end
  end

  describe '#set_domain_list' do
    let(:servers) { %w(foo bar baz) }

    before do
      node.config(['no ip domain-list foo',
                   'no ip domain-list bar',
                   'no ip domain-list baz'])
    end

    it 'add all the servers to the name servers list' do
      expect(subject.get[:domain_list]).to be_empty
      expect(subject.set_domain_list(value: servers)).to be_truthy
      expect(subject.get[:domain_list]).to eq(servers)
    end

    it 'negate the name servers list' do
      expect(subject.get[:domain_list]).to be_empty
      expect(subject.set_domain_list(enable: false)).to be_truthy
      expect(subject.get[:domain_list]).to be_empty
    end

    it 'default the name servers list' do
      expect(subject.get[:domain_list]).to be_empty
      expect(subject.set_domain_list(default: true)).to be_truthy
      expect(subject.get[:domain_list]).to be_empty
    end
  end

  describe '#add_domain_list' do
    before { node.config(['no ip domain-list arista.net']) }

    it 'adds the domain to the list' do
      expect(subject.get[:domain_list]).not_to include('arista.net')
      expect(subject.add_domain_list('arista.net')).to be_truthy
      expect(subject.get[:domain_list]).to include('arista.net')
    end
  end

  describe '#remove_name_server' do
    before { node.config(['ip domain-list arista.net']) }

    it 'adds the name-server to the list' do
      expect(subject.get[:domain_list]).to include('arista.net')
      expect(subject.remove_domain_list('arista.net')).to be_truthy
      expect(subject.get[:domain_list]).not_to include('arista.net')
    end
  end
end
