require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/snmp'

describe Rbeapi::Api::Snmp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:keys) do
      [:location, :contact, :chassis_id, :source_interface]
    end

    it 'has the required key in the resource hash' do
      keys.each do |key|
        expect(subject.get).to include(key)
      end
    end
  end

  describe '#set_notification' do
    before { node.config(['default snmp-server']) }

    it 'configures the snmp notification value to on' do
      expect(subject.set_notification(state: 'on',
                                      name: 'bgp')).to be_truthy
      expect(subject.get[:notifications][0]).to eq(name: 'bgp',
                                                   state: 'on')
    end

    it 'configures the snmp notification value to off' do
      expect(subject.set_notification(state: 'off',
                                      name: 'bgp')).to be_truthy
      expect(subject.get[:notifications][0]).to eq(name: 'bgp',
                                                   state: 'off')
    end

    it 'configures the snmp notification value to default' do
      expect(subject.set_notification(state: 'default',
                                      name: 'all')).to be_truthy
      expect(subject.get).to include(:notifications)
    end
  end

  describe '#set_location' do
    before { node.config(['no snmp-server location']) }

    it 'configures the snmp location value' do
      expect(subject.get[:location]).to be_empty
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
    end

    it 'negates the snmp location' do
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
      expect(subject.set_location(enable: false)).to be_truthy
      expect(subject.get[:location]).to be_empty
    end

    it 'defaults the snmp location' do
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
      expect(subject.set_location(default: true)).to be_truthy
      expect(subject.get[:location]).to be_empty
    end
  end

  describe '#set_contact' do
    before { node.config('no snmp-server contact') }

    it 'configures the snmp contact value' do
      expect(subject.get[:contact]).to be_empty
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
    end

    it 'negates the snmp contact' do
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
      expect(subject.set_contact(enable: false)).to be_truthy
      expect(subject.get[:contact]).to be_empty
    end

    it 'defaults the snmp contact' do
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
      expect(subject.set_contact(default: true)).to be_truthy
      expect(subject.get[:contact]).to be_empty
    end
  end

  describe '#set_chassis_id' do
    before { node.config('no snmp-server chassis-id') }

    it 'configures the snmp chassis-id value' do
      expect(subject.get[:chassis_id]).to be_empty
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
    end

    it 'negates the chassis id' do
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
      expect(subject.set_chassis_id(enable: false)).to be_truthy
      expect(subject.get[:chassis_id]).to be_empty
    end

    it 'defaults the chassis id' do
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
      expect(subject.set_chassis_id(default: true)).to be_truthy
      expect(subject.get[:chassis_id]).to be_empty
    end
  end

  describe '#set_source_interface' do
    before { node.config('no snmp-server source-interface') }

    it 'configures the snmp source-interface value' do
      expect(subject.get[:source_interface]).to be_empty
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
    end

    it 'negates the snmp source-interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(enable: false)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end

    it 'defaults the snmp source-interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(default: true)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end
  end

  describe '#add_community' do
    before { node.config('no snmp-server community foo') }

    it 'adds the specified community' do
      expect(subject.add_community('foo')).to be_truthy
      expect(subject.get[:communities]['foo'][:access]).to eq('ro')
    end

    it 'adds the specified community ro' do
      expect(subject.add_community('foo', 'ro')).to be_truthy
      expect(subject.get[:communities]['foo'][:access]).to eq('ro')
    end

    it 'adds the specified community rw' do
      expect(subject.add_community('foo', 'rw')).to be_truthy
      expect(subject.get[:communities]['foo'][:access]).to eq('rw')
    end
  end

  describe '#remove_community' do
    before { node.config('default snmp-server community foo') }

    it 'removes the specified community foo' do
      expect(subject.remove_community('foo')).to be_truthy
    end
  end

  describe '#set_community_access' do
    before { node.config('default snmp-server community foo') }

    it 'sets the community access to ro' do
      expect(subject.set_community_access('foo', 'ro')).to be_truthy
      expect(subject.get[:communities]['foo'][:access]).to eq('ro')
    end

    it 'sets the community access to rw' do
      expect(subject.set_community_access('foo', 'rw')).to be_truthy
      expect(subject.get[:communities]['foo'][:access]).to eq('rw')
    end
  end

  describe '#set_community_acl' do
    before do
      node.config(['no snmp-server community foo',
                   'no snmp-server community bar'])
    end

    it 'configures nil acl for snmp community foo and bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: nil)
      expect(subject.set_community_acl('bar')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: nil)
    end

    it 'configures IPv4 acl for snmp community foo and bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
    end

    it 'negates the snmp community ACL for bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
      # Remove bar
      expect(subject.set_community_acl('bar', enable: false)).to be_truthy
      expect(subject.get[:communities]['bar']).to be_falsy
      # Make sure foo is still there
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
    end

    it 'defaults the snmp community ACL for bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
      # Default bar
      expect(subject.set_community_acl('bar', default: true)).to be_truthy
      expect(subject.get[:communities]['bar']).to be_falsy
      # Make sure foo is still there
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
    end
  end
end
