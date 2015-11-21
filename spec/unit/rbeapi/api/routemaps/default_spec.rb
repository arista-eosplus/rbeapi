#
# Copyright (c) 2015, Arista Networks, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#   Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
#   Neither the name of Arista Networks nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'spec_helper'

require 'rbeapi/api/routemaps'

include FixtureHelpers

describe Rbeapi::Api::Routemaps do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    {
      'permit' => {
        10 => {
          match: ['interface Loopback0',
                  'ip address prefix-list MYLOOPBACK'],
          set: ['community internet 5555:5555'],
          description: 'description',
          continue: 99
        }
      }
    }
  end
  let(:name) { 'test1' }

  def routemaps
    routemaps = Fixtures[:routemaps]
    return routemaps if routemaps
    fixture('routemaps', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(routemaps)
  end

  describe '#getall' do
    let(:test1_entries) do
      {
        'test1' => {
          'permit' => {
            10 => {
              match: ['interface Loopback0',
                      'ip address prefix-list MYLOOPBACK'],
              set: ['community internet 5555:5555'],
              description: 'description',
              continue: 99
            }
          }
        },
        'test' => {
          'permit' => {
            10 => {
              match: ['interface Vlan100'],
              description: 'description',
              continue: 99
            },
            20 => {
              continue: 99,
              description: 'description',
              set: ['community internet 5555:5555']
            }
          },
          'deny' => {
            10 => {
              match: ['interface Vlan100'],
              description: 'description',
              continue: 99
            },
            20 => {
              continue: 99,
              description: 'description',
              set: ['community internet 5555:5555']
            }
          }
        }
      }
    end

    it 'returns the routemap collection' do
      expect(subject.getall).to include(test1_entries)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.getall.size).to eq(2)
    end
  end

  describe '#get' do
    it 'returns the routemap resource for given name' do
      expect(subject.get(name)).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get(name)).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get(name).size).to eq(1)
    end
  end

  describe '#create' do
    it 'create an existing routemap test1 permit 10' do
      expect(node).to receive(:config).with(['route-map test1 permit 10'])
      expect(subject.create('test1', 'permit', 10)).to be_truthy
    end

    it 'create an existing routemap test deny 20' do
      expect(node).to receive(:config).with(['route-map test deny 20'])
      expect(subject.create('test', 'deny', 20)).to be_truthy
    end

    it 'create a new routemap test4 permit 20' do
      expect(node).to receive(:config).with(['route-map test4 permit 20'])
      expect(subject.create('test4', 'permit', 20)).to be_truthy
    end

    it 'create a new routemap test4 permit 20 with enable false' do
      expect(node).to receive(:config).with(['no route-map test4 permit 20'])
      expect(subject.create('test4', 'permit', 20, enable: false)).to be_truthy
    end

    it 'create a new routemap test4 permit 20 with enable true' do
      expect(node).to receive(:config).with(['route-map test4 permit 20'])
      expect(subject.create('test4', 'permit', 20, enable: true)).to be_truthy
    end

    it 'add description to routemap test1 permit 10 with create' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10', 'no description',
               'description description'])
      expect(subject.create('test1', 'permit', 10,
                            description: 'description')).to be_truthy
    end

    it 'add description to routemap test deny 20 with create' do
      expect(node).to receive(:config)
        .with(['route-map test deny 20', 'no description',
               'description description'])
      expect(subject.create('test', 'deny', 20,
                            description: 'description')).to be_truthy
    end

    it 'add match statements to routemap test1 permit 10 with create' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10',
               'no match interface Loopback0',
               'no match ip address prefix-list MYLOOPBACK',
               'match ip address prefix-list MYLOOPBACK',
               'match interface Loopback0'])
      expect(subject.create('test1', 'permit', 10,
                            match: ['ip address prefix-list MYLOOPBACK',
                                    'interface Loopback0'])).to be_truthy
    end

    it 'add match statements to routemap test deny 20 with create' do
      expect(node).to receive(:config)
        .with(['route-map test deny 20',
               'match ip address prefix-list MYLOOPBACK',
               'match interface Loopback0'])
      expect(subject.create('test', 'deny', 20,
                            match: ['ip address prefix-list MYLOOPBACK',
                                    'interface Loopback0'])).to be_truthy
    end

    it 'add set statements to routemap test1 permit 10 with create' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10',
               'no set community internet 5555:5555',
               'set community internet 5555:5555'])
      expect(subject.create('test1', 'permit', 10,
                            set: ['community internet 5555:5555'])).to be_truthy
    end

    it 'add set statements to routemap test deny 20 with create' do
      expect(node).to receive(:config)
        .with(['route-map test deny 20',
               'no set community internet 5555:5555',
               'set community internet 5555:5555'])
      expect(subject.create('test', 'deny', 20,
                            set: ['community internet 5555:5555'])).to be_truthy
    end

    it 'add continue to routemap test1 permit 10 with create' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10', 'no continue', 'continue 99'])
      expect(subject.create('test1', 'permit', 10,
                            continue: 99)).to be_truthy
    end

    it 'add continue to routemap test deny 20 with create' do
      expect(node).to receive(:config)
        .with(['route-map test deny 20', 'no continue', 'continue 99'])
      expect(subject.create('test', 'deny', 20,
                            continue: 99)).to be_truthy
    end

    it 'default routemap test permit 10 with create' do
      expect(node).to receive(:config)
        .with(['default route-map test1 permit 10'])
      expect(subject.create('test1', 'permit', 10,
                            default: true)).to be_truthy
    end

    it 'default routemap test deny 20 with create' do
      expect(node).to receive(:config)
        .with(['default route-map test deny 20'])
      expect(subject.create('test', 'deny', 20,
                            default: true)).to be_truthy
    end
  end

  describe '#delete' do
    it 'delete test1 permit 10 routemap resource' do
      expect(node).to receive(:config).with(['no route-map test1 permit 10'])
      expect(subject.delete('test1', 'permit', 10)).to be_truthy
    end

    it 'delete test deny 20 routemap resource' do
      expect(node).to receive(:config).with(['no route-map test deny 20'])
      expect(subject.delete('test', 'deny', 20)).to be_truthy
    end

    it 'delete non existent routemap' do
      expect(node).to receive(:config).with(['no route-map blah deny 30'])
      expect(subject.delete('blah', 'deny', 30)).to be_truthy
    end
  end

  describe '#default' do
    it 'default test1 permit 10 routemap resource' do
      expect(node).to receive(:config)
        .with(['default route-map test1 permit 10'])
      expect(subject.default('test1', 'permit', 10)).to be_truthy
    end
  end

  describe '#set_match_statements' do
    it 'set the match statements on exsiting routemap' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10',
               'no match interface Loopback0',
               'no match ip address prefix-list MYLOOPBACK',
               'match ip address prefix-list MYLOOPBACK',
               'match interface Loopback0'])
      expect(
        subject
          .set_match_statements('test1', 'permit', 10,
                                ['ip address prefix-list MYLOOPBACK',
                                 'interface Loopback0'])
      ).to be_truthy
      expect(subject.get('test1').assoc('permit')[1].assoc(10)[1][:match])
        .to include('ip address prefix-list MYLOOPBACK',
                    'interface Loopback0')
    end

    it 'set the match statements on a new routemap' do
      expect(node).to receive(:config)
        .with(['route-map test4 permit 20',
               'match ip address prefix-list MYLOOPBACK',
               'match interface Loopback0'])
      expect(
        subject
          .set_match_statements('test4', 'permit', 20,
                                ['ip address prefix-list MYLOOPBACK',
                                 'interface Loopback0'])
      ).to be_truthy
    end
  end

  describe '#set_set_statements' do
    it 'set the set statements on existing routemap' do
      expect(node).to receive(:config)
        .with(['route-map test1 permit 10',
               'no set community internet 5555:5555',
               'set community internet 5555:5555'])
      expect(
        subject.set_set_statements('test1', 'permit', 10,
                                   ['community internet 5555:5555'])
      ).to be_truthy
      expect(subject.get('test1').assoc('permit')[1].assoc(10)[1][:set])
        .to include('community internet 5555:5555')
    end

    it 'set the set statements on new routemap' do
      expect(node).to receive(:config)
        .with(['route-map test4 permit 20',
               'set community internet 5555:5555'])
      expect(
        subject.set_set_statements('test4', 'permit', 20,
                                   ['community internet 5555:5555'])
      ).to be_truthy
    end
  end

  describe '#set_continue' do
    it 'set the continue statement on existing routemap' do
      expect(node).to receive(:config).with(['route-map test1 permit 10',
                                             'no continue',
                                             'continue 99'])
      expect(subject.set_continue('test1', 'permit', 10, 99)).to be_truthy
      expect(subject.get('test1').assoc('permit')[1]
        .assoc(10)[1][:continue]).to eq(99)
    end

    it 'set the continue statement on new routemap' do
      expect(node).to receive(:config).with(['route-map test4 permit 10',
                                             'no continue',
                                             'continue 99'])
      expect(subject.set_continue('test4', 'permit', 10, 99)).to be_truthy
    end
  end

  describe '#set_description' do
    it 'set the description statement on existing routemap' do
      expect(node).to receive(:config).with(['route-map test1 permit 10',
                                             'no description',
                                             'description description'])
      expect(subject.set_description('test1', 'permit', 10,
                                     'description')).to be_truthy
      expect(subject.get('test1')
        .assoc('permit')[1].assoc(10)[1][:description])
        .to eq('description')
    end

    it 'set the description statement on new routemap' do
      expect(node).to receive(:config).with(['route-map test4 permit 20',
                                             'no description',
                                             'description description'])
      expect(subject.set_description('test4', 'permit', 20,
                                     'description')).to be_truthy
    end
  end
end
