require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/interfaces'

describe Rbeapi::Api::Interfaces do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:entity) do
      { name: 'Port-Channel1', type: 'portchannel', description: '',
        encapsulation: '', shutdown: false, load_interval: '', members: [],
        lacp_mode: 'on', minimum_links: '0', lacp_timeout: '90',
        lacp_fallback: 'disabled' }
    end

    before do
      node.config(['no interface Port-Channel1', 'interface Port-Channel1'])
    end

    it 'returns the interface resource' do
      expect(subject.get('Port-Channel1')).to eq(entity)
    end
  end

  describe '#getall' do
    before do
      node.config(['no interface Port-Channel1', 'interface Port-Channel1'])
    end

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

  describe '#create' do
    before { node.config('no interface Port-Channel1.1') }

    it 'creates a new subinterface resource' do
      expect(subject.get('Port-Channel1.1')).to be_nil
      expect(subject.create('Port-Channel1.1')).to be_truthy
      expect(subject.get('Port-Channel1.1')).not_to be_nil
      node.config(['no interface Port-Channel1.1'])
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

  describe '#delete' do
    before { node.config(['interface Port-Channel1.1']) }

    it 'deletes a switchport subinterface resource' do
      ##      expect(subject.get('Port-Channel1.1')).not_to be_nil
      expect(subject.delete('Port-Channel1.1')).to be_truthy
      expect(subject.get('Port-Channel1.1')).to be_nil
    end
  end

  describe '#default' do
    before { node.config(['interface Port-Channel1', :shutdown]) }

    it 'sets Port-Channel1 to default' do
      expect(subject.get('Port-Channel1')[:shutdown]).to be_truthy
      expect(subject.default('Port-Channel1')).to be_truthy
      expect(subject.get('Port-Channel1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_description' do
    it 'sets the description value on the interface' do
      node.config(['interface Port-Channel1', 'no description'])
      expect(subject.get('Port-Channel1')[:description]).to be_empty
      expect(subject.set_description('Port-Channel1', value: 'foo bar'))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:description]).to eq('foo bar')
    end
  end

  describe '#set_encapsulation' do
    it 'sets the encapsulation value on the interface' do
      node.config(['interface Port-Channel1.1', 'no encapsulation dot1q vlan'])
      expect(subject.get('Port-Channel1.1')[:encapsulation]).to be_empty
      expect(subject.set_encapsulation('Port-Channel1.1', value: '31'))
        .to be_truthy
      expect(subject.get('Port-Channel1.1')[:encapsulation]).to eq('31')
      node.config(['no interface Port-Channel1.1'])
    end
  end

  describe '#set_shutdown' do
    it 'shutdown the interface' do
      node.config(['interface Port-Channel1', 'no shutdown'])
      expect(subject.get('Port-Channel1')[:shutdown]).to be_falsy
      expect(subject.set_shutdown('Port-Channel1', enable: false)).to be_truthy
      expect(subject.get('Port-Channel1')[:shutdown]).to be_truthy
    end

    it 'enable the interface' do
      node.config(['interface Port-Channel1', 'shutdown'])
      expect(subject.get('Port-Channel1')[:shutdown]).to be_truthy
      expect(subject.set_shutdown('Port-Channel1', enable: true)).to be_truthy
      expect(subject.get('Port-Channel1')[:shutdown]).to be_falsy
    end
  end

  describe '#set_minimum_links' do
    before do
      node.config(['interface Port-Channel1',
                   'port-channel min-links 0'])
    end

    it 'sets the minimum links value on the interface' do
      expect(subject.get('Port-Channel1')[:minimum_links]).to eq('0')
      expect(subject.set_minimum_links('Port-Channel1', value: '2'))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:minimum_links]).to eq('2')
    end
  end

  describe '#set_members' do
    before do
      node.config(['no interface Port-Channel1',
                   'interface Port-Channel1'])
    end

    it 'adds new members to the port-channel interface' do
      node.config(['no interface Port-Channel1', 'interface Port-Channel1'])
      expect(subject.get('Port-Channel1')[:members]).not_to include('Ethernet1')
      expect(subject.set_members('Port-Channel1', ['Ethernet1'])).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(['Ethernet1'])
    end

    it 'updates the member interfaces on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.set_members('Port-Channel1',
                                 %w(Ethernet1 Ethernet3))).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet3))
    end

    it 'updates the member interfaces and mode on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
      expect(subject.set_members('Port-Channel1',
                                 %w(Ethernet1 Ethernet3),
                                 'active')).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet3))
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('active')
    end
  end

  describe '#add_member' do
    before do
      node.config(['no interface Port-Channel1',
                   'interface Port-Channel1'])
    end

    it 'adds new members to the port-channel interface' do
      node.config(['no interface Port-Channel1', 'interface Port-Channel1'])
      expect(subject.get('Port-Channel1')[:members]).not_to include('Ethernet1')
      expect(subject.add_member('Port-Channel1', 'Ethernet1')).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(['Ethernet1'])
    end

    it 'updates the member interfaces on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.add_member('Port-Channel1', 'Ethernet3')).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2
                                                              Ethernet3))
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
    end

    it 'no update to the member interfaces on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                   'channel-group 1 mode active'])
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.add_member('Port-Channel1', 'Ethernet2')).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('active')
    end
  end

  describe '#remove_member' do
    before do
      node.config(['no interface Port-Channel1',
                   'interface Port-Channel1'])
    end

    it 'removes the member interface on existing interface' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-2',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:members]).to eq(%w(Ethernet1
                                                              Ethernet2))
      expect(subject.remove_member('Port-Channel1', 'Ethernet1')).to be_truthy
      expect(subject.get('Port-Channel1')[:members]).to eq(['Ethernet2'])
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
    end
  end

  describe '#set_lacp_mode' do
    it 'sets the lacp mode on the port-channel to active' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
      expect(subject.set_lacp_mode('Port-Channel1', 'active')).to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('active')
    end

    it 'sets the lacp mode on the port-channel to passive' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                   'channel-group 1 mode on'])
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
      expect(subject.set_lacp_mode('Port-Channel1', 'passive')).to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('passive')
    end

    it 'sets the lacp mode on the port-channel to on' do
      node.config(['no interface Port-Channel1', 'interface Ethernet1-3',
                   'channel-group 1 mode active'])
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('active')
      expect(subject.set_lacp_mode('Port-Channel1', 'on')).to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_mode]).to eq('on')
    end
  end

  describe '#set_lacp_fallback' do
    it 'sets the lacp fallback on the port-channel to static' do
      node.config(['interface Port-Channel1', 'no port-channel lacp fallback'])
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('disabled')
      expect(subject.set_lacp_fallback('Port-Channel1', value: 'static'))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('static')
    end

    it 'sets the lacp fallback on the port-channel to individual' do
      node.config(['interface Port-Channel1', 'no port-channel lacp fallback'])
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('disabled')
      expect(subject.set_lacp_fallback('Port-Channel1', value: 'individual'))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('individual')
    end

    it 'sets the lacp fallback on the port-channel to disabled' do
      node.config(['interface Port-Channel1',
                   'port-channel lacp fallback static'])
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('static')
      expect(subject.set_lacp_fallback('Port-Channel1', enable: false))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_fallback]).to eq('disabled')
    end
  end

  describe '#set_lacp_timeout' do
    before do
      node.config(['interface Port-Channel1',
                   'default port-channel lacp fallback timeout'])
    end

    it 'sets the lacp fallback timeout value on the interface' do
      expect(subject.get('Port-Channel1')[:lacp_timeout]).to eq('90')
      expect(subject.set_lacp_timeout('Port-Channel1', value: '100'))
        .to be_truthy
      expect(subject.get('Port-Channel1')[:lacp_timeout]).to eq('100')
    end
  end

  describe '#set_load_interval' do
    before do
      node.config(['interface Port-Channel1', 'default load-interval'])
    end

    it 'sets the load-interval value on the interface' do
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('')
      expect(subject.set_load_interval('Port-Channel1',
                                       value: '10')).to be_truthy
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('10')
    end

    it 'negates the load-interval' do
      expect(subject.set_load_interval('Port-Channel1',
                                       value: '20')).to be_truthy
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('20')
      expect(subject.set_load_interval('Port-Channel1',
                                       enable: false)).to be_truthy
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('')
    end

    it 'defaults the load-interval' do
      expect(subject.set_load_interval('Port-Channel1',
                                       value: '10')).to be_truthy
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('10')
      expect(subject.set_load_interval('Port-Channel1',
                                       default: true)).to be_truthy
      expect(subject.get('Port-Channel1')[:load_interval]).to eq('')
    end
  end
end
