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
      node.config(['no route-map test', 'no route-map test1',
                   'no route-map test2', 'no route-map test3',
                   'route-map test permit 10',
                   'route-map test permit 20', 'description descript',
                   'match ip address prefix-list MYLOOPBACK',
                   'match interface Loopback0',
                   'set community internet 5555:5555', 'continue 99'])
    end

    it 'returns a routemap resource instance' do
      expect(subject.get('test')).to be_a_kind_of(Hash)
    end

    it 'has a key for description' do
      expect(subject.get('test').assoc('permit')[1].assoc(20)[1])
        .to include(:description)
    end

    it 'has a key for continue' do
      expect(subject.get('test').assoc('permit')[1].assoc(20)[1])
        .to include(:continue)
    end

    it 'has a key for match' do
      expect(subject.get('test').assoc('permit')[1].assoc(20)[1])
        .to include(:match)
    end

    it 'has a key for set' do
      expect(subject.get('test').assoc('permit')[1].assoc(20)[1])
        .to include(:set)
    end
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    before do
      node.config(['no route-map test', 'no route-map test1',
                   'route-map test1 permit 10', 'continue 99',
                   'route-map test permit 10',
                   'route-map test permit 20', 'description descript',
                   'match ip address prefix-list MYLOOPBACK',
                   'match interface Loopback0',
                   'set community internet 5555:5555', 'continue 99'])
    end

    let(:test1_entries) do
      {
        'test1' => {
          'permit' => {
            10 => {
              continue: 99
            }
          }
        },
        'test' => {
          'permit' => {
            10 => {},
            20 => {
              continue: 99,
              description: 'descript',
              match: ['ip address prefix-list MYLOOPBACK',
                      'interface Loopback0'],
              set: ['community internet 5555:5555']
            }
          }
        }
      }
    end

    it 'returns a routemap resource instance' do
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
    let(:test_entry) do
      {
        'permit' => {
          20 => {
            continue: 99,
            description: 'descript',
            match: ['ip address prefix-list MYLOOPBACK',
                    'interface Loopback0'],
            set: ['community internet 5555:5555']
          }
        }
      }
    end

    before do
      node.config(['no route-map test', 'no route-map test1'])
    end

    it 'creates the routemap with all options' do
      expect(subject.get('test')).to eq(nil)
      expect(subject
              .create('test', 'permit', 20,
                      continue: 99, description: 'descript',
                      match: ['ip address prefix-list MYLOOPBACK',
                              'interface Loopback0'],
                      set: ['community internet 5555:5555'])
            ).to be_truthy
      expect(subject.get('test')).to eq(test_entry)
    end

    it 'creates the routemap with no options' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject.create('test1', 'permit', 10)).to be_truthy
      expect(subject.get('test1')).to be_truthy
      expect(subject.get('test1').assoc('permit')[0]).to eq('permit')
      expect(
        subject.get('test1').assoc('permit')[1].assoc(10)[0]).to eq(10)
      expect(
        subject.get('test1').assoc('permit')[1].assoc(10)[1][:continue]
      ).to eq(nil)
      expect(
        subject.get('test1').assoc('permit')[1].assoc(10)[1][:description]
      ).to eq(nil)
      expect(
        subject.get('test1').assoc('permit')[1].assoc(10)[1][:match]
      ).to eq(nil)
      expect(
        subject.get('test1').assoc('permit')[1].assoc(10)[1][:set]
      ).to eq(nil)
    end
  end

  describe '#delete' do
    before do
      node.config(['route-map test',
                   'route-map test1 permit 20',
                   'route-map test1 permit 10',
                   'route-map test2 permit 10',
                   'route-map test2 permit 20'])
    end

    it 'removes the routemap' do
      expect(subject.get('test')).to eq('permit' => { 10 => {} })
      expect(subject.delete('test', 'permit', 10)).to be_truthy
      expect(subject.get('test')).to eq(nil)
    end

    it 'removes multiple routemaps with same name' do
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => {}, 20 => {} })
      expect(subject.delete('test1', 'permit', 20)).to be_truthy
      expect(subject.get('test1')).to eq('permit' => { 10 => {} })
    end
  end

  describe '#delete' do
    before do
      node.config(['route-map test',
                   'route-map test1 permit 20',
                   'route-map test1 permit 10',
                   'route-map test2 permit 10',
                   'route-map test2 permit 20'])
    end

    it 'removes the routemap' do
      expect(subject.get('test')).to eq('permit' => { 10 => {} })
      expect(subject.delete('test', 'permit', 10)).to be_truthy
      expect(subject.get('test')).to eq(nil)
    end

    it 'removes multiple routemaps with same name' do
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => {}, 20 => {} })
      expect(subject.delete('test1', 'permit', 20)).to be_truthy
      expect(subject.get('test1')).to eq('permit' => { 10 => {} })
    end
  end

  describe '#set_match_statements' do
    before do
      node.config(['route-map test permit 10',
                   'no match ip address prefix-list MYLOOPBACK',
                   'no match interface Vlan100',
                   'no match interface Loopback1',
                   'match interface Loopback1',
                   'no route-map test1'])
    end

    it 'sets match statements on an existing routemap' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Loopback1'] } })
      expect(
        subject.set_match_statements('test', 'permit', 10,
                                     ['ip address prefix-list MYLOOPBACK',
                                      'interface Loopback0'])).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => {
                 match: ['ip address prefix-list MYLOOPBACK',
                         'interface Loopback0'] } })
    end

    it 'adds more match statements' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Loopback1'] } })
      expect(subject.set_match_statements('test', 'permit', 10,
                                          ['interface Vlan100'])).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Vlan100'] } })
      expect(subject
        .set_match_statements('test', 'permit', 10,
                              ['interface Vlan100',
                               'ip address prefix-list MYLOOPBACK'])
            ).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => {
                 match: ['ip address prefix-list MYLOOPBACK',
                         'interface Vlan100'] } })
      expect(subject
        .set_match_statements('test', 'permit', 10,
                              ['interface Vlan100'])).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Vlan100'] } })
    end

    it 'adds match statements to a new seqno' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Loopback1'] } })
      expect(subject.set_match_statements('test', 'permit', 20,
                                          ['interface Vlan100'])).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { match: ['interface Loopback1'] },
                             20 => { match: ['interface Vlan100'] } })
    end

    it 'set match statements on a new routemap' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject.set_match_statements('test1', 'permit', 10,
                                          ['ip address prefix-list MYLOOPBACK',
                                           'interface Loopback0'])).to be_truthy
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => {
                 match: ['ip address prefix-list MYLOOPBACK',
                         'interface Loopback0'] } })
    end
  end

  describe '#set_set_statements' do
    before do
      node.config(['no route-map test', 'no route-map test1',
                   'route-map test permit 10',
                   'set community internet 3333:3333'])
    end

    it 'set set statements on an existing routemap' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { set: ['community internet 3333:3333'] } })
      expect(subject
          .set_set_statements('test', 'permit', 10,
                              ['origin igp'])).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { set: ['origin igp'] } })
    end

    it 'set set statements on a new routemap' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject
        .set_set_statements('test1', 'permit', 10,
                            ['community internet 5555:5555',
                             'community internet 4444:4444'])).to be_truthy
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => {
                 set: ['community internet 4444:4444 5555:5555'] } })
    end
  end

  describe '#set_continue' do
    before do
      node.config(['no route-map test', 'no route-map test1',
                   'route-map test permit 10', 'continue 50'])
    end

    it 'set continue on an existing routemap' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { continue: 50 } })
      expect(subject.set_continue('test', 'permit', 10, 99)).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { continue: 99 } })
    end

    it 'set continue on a new routemap' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject.set_continue('test1', 'permit', 10, 99)).to be_truthy
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => { continue: 99 } })
    end
  end

  describe '#set_description' do
    before do
      node.config(['no route-map test', 'no route-map test1',
                   'route-map test permit 10', 'description temp'])
    end

    it 'set description on an existing routemap' do
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { description: 'temp' } })
      expect(subject
        .set_description('test', 'permit', 10, 'descript')).to be_truthy
      expect(subject.get('test'))
        .to eq('permit' => { 10 => { description: 'descript' } })
    end

    it 'set description on a new routemap' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject
        .set_description('test1', 'permit', 10,
                         'descript')).to be_truthy
      expect(subject.get('test1'))
        .to eq('permit' => { 10 => { description: 'descript' } })
    end
  end
end
