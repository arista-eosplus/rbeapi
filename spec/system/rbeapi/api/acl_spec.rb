require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/acl'

describe Rbeapi::Api::Acl do
  subject { described_class.new(node) }

  let(:config) { Rbeapi::Client::Config.new(filename: get_fixture('dut.conf')) }
  let(:node) { Rbeapi::Client.connect_to('dut') }

  before do
    node.config(['no ip access-list standard test1',
                 'ip access-list standard test1',
                 'permit host 1.2.3.4 log',
                 'permit 1.2.3.4 255.255.0.0 log',
                 'deny any',
                 'permit 5.6.7.0/24',
                 'permit 9.10.11.0 255.255.255.0 log',
                 'exit'])
    node.config(['no ip access-list standard test2',
                 'ip access-list standard test2',
                 'deny 16.0.0.0/8',
                 'exit'])
  end

  let(:test1_entries) do
    { '10' => { seqno: '10', action: 'permit', srcaddr: '1.2.3.4',
                srcprefixlen: '255.255.255.255', log: 'log' },
      '20' => { seqno: '20', action: 'permit', srcaddr: '1.2.3.4',
                srcprefixlen: '255.255.0.0', log: 'log' },
      '30' => { seqno: '30', action: 'deny', srcaddr: '0.0.0.0',
                srcprefixlen: '255.255.255.255', log: nil },
      '40' => { seqno: '40', action: 'permit', srcaddr: '5.6.7.0',
                srcprefixlen: '24', log: nil },
      '50' => { seqno: '50', action: 'permit', srcaddr: '9.10.11.0',
                srcprefixlen: '255.255.255.0', log: 'log' } }
  end

  let(:test2_entries) do
    { '10' => { seqno: '10', action: 'deny', srcaddr: '16.0.0.0',
                srcprefixlen: '8', log: nil } }
  end

  describe '#get' do
    it 'returns the test ACL entries' do
      expect(subject.get('test1')).to eq(test1_entries)
      expect(subject.get('test2')).to eq(test2_entries)
    end
  end

  describe '#getall' do
    let(:collection) { subject.getall }

    it 'includes test1 and test2 ACLs' do
      expect(collection).to include('test1')
      expect(collection).to include('test2')
    end

    it 'is a kind of hash' do
      expect(collection).to be_a_kind_of(Hash)
    end
  end

  describe '#create' do
    before { node.config('no ip access-list standard abc') }

    it 'creates a new ACL resource' do
      expect(subject.get('abc')).to be_nil
      expect(subject.create('abc')).to be_truthy
      expect(subject.get('abc')).not_to be_nil
    end
  end

  describe '#delete' do
    it 'deletes the abc ACL resource' do
      expect(subject.get('abc')).not_to be_nil
      expect(subject.delete('abc')).to be_truthy
      expect(subject.get('abc')).to be_nil
    end
  end

  describe '#default' do
    before { node.config('ip access-list standard xyz') }

    it 'sets ACL xyz to default value' do
      expect(subject.get('xyz')).to be_truthy
      expect(subject.default('xyz')).to be_truthy
      expect(subject.get('xyz')).to be_nil
    end
  end

  describe '#update_entry' do
    let(:update_entry) do
      { seqno: '50', action: 'deny', srcaddr: '100.0.0.0',
        srcprefixlen: '8', log: nil }
    end

    it 'Change entry 50 to values in update_entry' do
      expect(subject.get('test1')['50'][:action]).to eq('permit')
      expect(subject.update_entry('test1', update_entry)).to be_truthy
      expect(subject.get('test1')['50']).to eq(update_entry)
    end
  end

  describe '#add_entry' do
    let(:new_entry) do
      { seqno: '60', action: 'deny', srcaddr: '1.2.3.0',
        srcprefixlen: '24', log: 'log' }
    end

    it 'Add entry 60 to the test1 ACL' do
      expect(subject.get('test1')['60']).to be_nil
      expect(subject.add_entry('test1', new_entry)).to be_truthy
      expect(subject.get('test1')['60']).to eq(new_entry)
    end
  end

  describe '#remove_entry' do
    it 'Remove entry 30 from the test1 ACL' do
      expect(subject.get('test1')['30']).to be_truthy
      expect(subject.remove_entry('test1', '30')).to be_truthy
      expect(subject.get('test1')['30']).to be_nil
    end
  end
end
