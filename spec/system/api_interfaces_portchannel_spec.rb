require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/interfaces'

describe Rbeapi::Api::Interfaces do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('veos02') }

  describe '#get' do

    let(:entity) do
      { 'name' => 'Port-Channel1', 'type' => 'portchannel', 'description' => '',
        'shutdown' => false, 'members' => [], 'lacp_mode' => 'on',
        'minimum_links' => '0', 'lacp_timeout' => '90',
        'lacp_fallback' => 'disabled' }
    end

    before { node.config(['no interface Port-Channel1', 'interface Port-Channel1']) }

    it 'returns the interface resource' do
      expect(subject.get('Port-Channel1')).to eq(entity)
    end
  end

  describe '#getall' do
    before { node.config(['no interface Port-Channel1', 'interface Port-Channel1']) }

    it 'returns the interface collection' do
      expect(subject.getall).to include('Port-Channel1')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
 end

  describe '#create' do
    before { node.config('no interface Port-Channel1') }

    it 'creates a new interface resource' do
      expect(subject.get('Port-Channel1')).to be_nil
      expect(subject.create('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')).not_to be_nil
    end
  end

  describe '#delete' do
    before { node.config(['interface Port-Channel1']) }

    it 'deletes a switchport resource' do
      expect(subject.get('Port-Channel1')).not_to be_nil
      expect(subject.delete('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Port-Channel1', 'shutdown']) }

    it 'sets Port-Channel1 to default' do
      expect(subject.get('Port-Channel1')['shutdown']).to be_truthy
      expect(subject.default('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')['shutdown']).to be_falsy
    end
  end

  describe '#set_description' do
    it 'sets the description value on the interface' do
      node.config(['interface Port-Channel1', 'no description'])
      expect(subject.get('Port-Channel1')['description']).to be_empty
      expect(subject.set_description('Port-Channel1', value: 'foo bar')).to be_truthy
      expect(subject.get('Port-Channel1')['description']).to eq('foo bar')
    end
  end

  describe '#set_shutdown' do
    it 'sets the shutdown value to true' do
      node.config(['interface Port-Channel1', 'no shutdown'])
      expect(subject.get('Port-Channel1')['shutdown']).to be_falsy
      expect(subject.set_shutdown('Port-Channel1', value: true)).to be_truthy
      expect(subject.get('Port-Channel1')['shutdown']).to be_truthy
    end

    it 'sets the shutdown value to false' do
      node.config(['interface Port-Channel1', 'shutdown'])
      expect(subject.get('Port-Channel1')['shutdown']).to be_truthy
      expect(subject.set_shutdown('Port-Channel1', value: false)).to be_truthy
      expect(subject.get('Port-Channel1')['shutdown']).to be_falsy
    end
  end

  describe '#set_minimum_links' do
    before { node.config(['interface Port-Channel1',
                          'port-channel min-links 0']) }

    it 'sets the minimum links value on the interface' do
      expect(subject.get('Port-Channel1')['minimum_links']).to eq('0')
      expect(subject.set_minimum_links('Port-Channel1', value: '2')).to be_truthy
      expect(subject.get('Port-Channel1')['minimum_links']).to eq('2')
    end
  end

  describe '#set_members' do
    before { node.config(['no interface Port-Channel1',
                          'interface Port-Channel1']) }

    it 'adds new members to the port-channel interface' do
      node.config(['no interface Port-Channel1', 'interface Port-Channel1'])
      expect(subject.get('Port-Channel1')['members']).not_to include('Ethernet1')
      expect(subject.set_members('Port-Channel1', ['Ethernet1'])).to be_truthy
      expect(subject.get('Port-Channel1')['members']).to eq(['Ethernet1'])
    end

    it 'updates the member interfaces on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                  'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')['members']).to eq(['Ethernet1', 'Ethernet2'])
      expect(subject.set_members('Port-Channel1', ['Ethernet1', 'Ethernet3'])).to be_truthy
      expect(subject.get('Port-Channel1')['members']).to eq(['Ethernet1', 'Ethernet3'])
    end
  end

  describe '#set_lacp_mode' do
    it 'sets the lacp mode on the port-channel to active' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                  'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('on')
      expect(subject.set_lacp_mode('Port-Channel1', 'active')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('active')
    end

    it 'sets the lacp mode on the port-channel to passive' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                  'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('on')
      expect(subject.set_lacp_mode('Port-Channel1', 'passive')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('passive')
    end

    it 'sets the lacp mode on the port-channel to on' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                  'channel-group 1 mode active'])
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('active')
      expect(subject.set_lacp_mode('Port-Channel1', 'on')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_mode']).to eq('on')
    end
  end

  describe '#set_lacp_fallback' do
    it 'sets the lacp fallback on the port-channel to static' do
      node.config(['interface Port-Channel1', 'no port-channel lacp fallback'])
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('disabled')
      expect(subject.set_lacp_fallback('Port-Channel1', value: 'static')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('static')
    end

    it 'sets the lacp fallback on the port-channel to individual' do
      node.config(['interface Port-Channel1', 'no port-channel lacp fallback'])
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('disabled')
      expect(subject.set_lacp_fallback('Port-Channel1', value: 'individual')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('individual')
    end

    it 'sets the lacp fallback on the port-channel to disabled' do
      node.config(['interface Port-Channel1', 'port-channel lacp fallback static'])
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('static')
      expect(subject.set_lacp_fallback('Port-Channel1', value: 'disabled')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_fallback']).to eq('disabled')
    end
  end

  describe '#set_lacp_timeout' do
    before { node.config(['interface Port-Channel1',
                          'default port-channel lacp fallback timeout']) }

    it 'sets the lacp fallback timeout value on the interface' do
      expect(subject.get('Port-Channel1')['lacp_timeout']).to eq('90')
      expect(subject.set_lacp_timeout('Port-Channel1', value: '100')).to be_truthy
      expect(subject.get('Port-Channel1')['lacp_timeout']).to eq('100')
    end
  end
end

