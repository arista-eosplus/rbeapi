require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/routemaps'

describe Rbeapi::Api::Routemaps do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:resource) { subject.get }

    before do
      node.config(['no route-map test:10', 'no route-map test:20',
                   'route-map test:10 permit 20', 'description descript',
                   'match ip address prefix-list MYLOOPBACK',
                   'match interface Loopback0',
                   'set community internet 5555:5555', 'continue 99'])
    end

    it 'returns a varp resource instance' do
      expect(subject.get('test:10')).to be_a_kind_of(Hash)
    end

    it 'has a key for description' do
      expect(subject.get('test:10')).to include(:description)
    end

    it 'has a key for continue' do
      expect(subject.get('test:10')).to include(:continue)
    end

    it 'has a key for match_rules' do
      expect(subject.get('test:10')).to include(:match_rules)
    end

    it 'has a key for set_rules' do
      expect(subject.get('test:10')).to include(:set_rules)
    end
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    before do
      node.config(['no route-map test:10', 'no route-map test:20',
                   'route-map test:20 permit 10', 'continue 99',
                   'route-map test:10 permit 20', 'description descript',
                   'match ip address prefix-list MYLOOPBACK',
                   'match interface Loopback0',
                   'set community internet 5555:5555', 'continue 99'])
    end

    let(:test1_entries) do
      {
        'test:20' => { action: 'permit',
                       seqno: 10,
                       continue: 99 },
        'test:10' => { action: 'permit',
                       seqno: 20,
                       continue: 99,
                       description: 'descript',
                       match_rules: ['ip address prefix-list MYLOOPBACK',
                                     'interface Loopback0'],
                       set_rules: ['community internet 5555:5555'] }
      }
    end

    it 'returns a varp resource instance' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has a key for description' do
      expect(subject.getall.count).to eq(2)
    end

    it 'returns the routemap collection' do
      expect(subject.getall).to include(test1_entries)
    end
  end

  describe '#create' do
    before do
      node.config(['no route-map test:10', 'no route-map test:20'])
    end

    it 'creates the routemap' do
      expect(subject.get('test:10')).to be_empty
      expect(subject
              .create('test:10',
                      action: 'permit', seqno: 20,
                      continue: 99, description: 'descript',
                      match_rules: ['ip address prefix-list MYLOOPBACK',
                                    'interface Loopback0'],
                      set_rules: ['community internet 5555:5555'])
            ).to be_truthy
      expect(subject.get('test:10')).to be_truthy
    end
  end
end
