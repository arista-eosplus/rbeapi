#
# Copyright (c) 2016, Arista Networks, Inc.
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

require 'rbeapi/api/prefixlists'

include FixtureHelpers

describe Rbeapi::Api::Prefixlists do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def prefixlists
    prefixlists = Fixtures[:prefixlists]
    return prefixlists if prefixlists
    fixture('prefixlists', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(prefixlists)
  end

  describe '#get' do
    let(:keys) { %w(seq action prefix) }

    [
      { title: 'single-line',
        prefix_list: 'test5',
        rules: [{ 'seq' => '10',
                  'action' => 'permit',
                  'prefix' => '10.50.1.0/24' },
                { 'seq' => '20',
                  'action' => 'permit',
                  'prefix' => '10.50.2.0/24' }] },
      { title: 'multi-line',
        prefix_list: 'test1',
        rules: [{ 'seq' => '10',
                  'action' => 'permit',
                  'prefix' => '10.10.1.0/24' },
                { 'seq' => '20',
                  'action' => 'permit',
                  'prefix' => '10.20.1.0/24 le 30' },
                { 'seq' => '30',
                  'action' => 'permit',
                  'prefix' => '10.30.1.0/24 ge 26 le 30' }] }
    ].each do |context|
      context "when prefix list is #{context[:title]}" do
        let(:resource) { subject.get(context[:prefix_list]) }

        it 'returns the correct rules' do
          expect(resource).to eq(context[:rules])
        end

        it 'returns an array of rules' do
          expect(resource).to be_a_kind_of(Array)
        end

        it "has #{context[:rules].size} rules" do
          expect(resource.size).to eq(context[:rules].size)
        end

        it 'has all keys' do
          resource.each do |rule|
            expect(rule.keys).to match_array(keys)
          end
        end
      end
    end

    let(:nonexistent) { subject.get('nonexistent') }
    it 'returns nil for a non-existing name' do
      expect(nonexistent).to eq(nil)
    end
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    let(:plists) do
      {
        'test1' => [
          { 'seq' => '10',
            'action' => 'permit',
            'prefix' => '10.10.1.0/24' },
          { 'seq' => '20',
            'action' => 'permit',
            'prefix' => '10.20.1.0/24 le 30' },
          { 'seq' => '30',
            'action' => 'permit',
            'prefix' => '10.30.1.0/24 ge 26 le 30' }
        ],
        'test2' => [
          { 'seq' => '10',
            'action' => 'permit',
            'prefix' => '10.11.0.0/16' },
          { 'seq' => '20',
            'action' => 'permit',
            'prefix' => '10.12.0.0/16 le 24' }
        ],
        'test3' => [],
        'test4' => [
          { 'seq' => '10',
            'action' => 'permit',
            'prefix' => '10.14.0.0/16 le 20' }
        ],
        'test5' => [
          { 'seq' => '10',
            'action' => 'permit',
            'prefix' => '10.50.1.0/24' },
          { 'seq' => '20',
            'action' => 'permit',
            'prefix' => '10.50.2.0/24' }
        ]
      }
    end

    it 'returns all prefix lists' do
      expect(resource).to eq(plists)
    end

    it 'returns a hash' do
      expect(resource).to be_a_kind_of(Hash)
    end

    it 'has five prefix lists' do
      expect(resource.size).to eq(5)
    end
  end

  describe '#create' do
    it 'creates a new prefix list' do
      expect(node).to receive(:config).with('ip prefix-list plist1')
      expect(subject.create('plist1')).to be_truthy
    end

    it 'creates an existing prefix list' do
      expect(node).to receive(:config).with('ip prefix-list test1')
      expect(subject.create('test1')).to be_truthy
    end
  end

  describe '#add_rule' do
    it 'adds rule to existing prefix list' do
      expect(node).to receive(:config)
        .with('ip prefix-list test1 seq 25 permit 10.25.1.0/24')
      expect(subject.add_rule('test1', 'permit', '10.25.1.0/24', '25'))
        .to be_truthy
    end

    it 'adds rule to existing prefix list w/o seq' do
      expect(node).to receive(:config)
        .with('ip prefix-list test1 permit 10.25.2.0/24')
      expect(subject.add_rule('test1', 'permit', '10.25.2.0/24'))
        .to be_truthy
    end

    it 'adds rule to non-existing prefix list' do
      expect(node).to receive(:config)
        .with('ip prefix-list plist2 seq 10 permit 10.25.3.128/25')
      expect(subject.add_rule('plist2', 'permit', '10.25.3.128/25', '10'))
        .to be_truthy
    end

    it 'adds rule to non-existing prefix list w/o seq' do
      expect(node).to receive(:config)
        .with('ip prefix-list plist2 deny 10.25.10.0/25')
      expect(subject.add_rule('plist2', 'deny', '10.25.10.0/25'))
        .to be_truthy
    end

    it 'overwrites existing rule' do
      expect(node).to receive(:config)
        .with('ip prefix-list test1 seq 20 permit 10.25.20.0/24 le 28')
      expect(subject.add_rule('test1', 'permit', '10.25.20.0/24 le 28', '20'))
        .to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes a prefix-list' do
      expect(node).to receive(:config).with('no ip prefix-list test1')
      expect(subject.delete('test1'))
    end

    it 'deletes a rule from a prefix-list' do
      expect(node).to receive(:config).with('no ip prefix-list test2 seq 10')
      expect(subject.delete('test2', '10'))
    end
  end
end
