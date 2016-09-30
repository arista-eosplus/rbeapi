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

require 'rbeapi/client'
require 'rbeapi/api/prefixlists'

describe Rbeapi::Api::Prefixlists do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    before do
      node.config(['no ip prefix-list test1',
                   'ip prefix-list test1 seq 10 permit 1.2.3.0/24',
                   'ip prefix-list test1 seq 20 permit 2.3.4.0/24 le 30',
                   'ip prefix-list test1 seq 30 deny 3.4.5.0/24 ge 26 le 30',
                   'ip prefix-list test1 permit 5.6.7.16/28 eq 29'])
    end

    let(:prefixlist) { subject.get('test1') }

    it 'returns the prefix list for an existing name' do
      expect(prefixlist).to be_a_kind_of(Array)
    end

    it 'returns all rules as hash' do
      expect(prefixlist).to all ( be_an(Hash) )
    end

    it 'has all keys for each rule' do
      prefixlist.each do |rule|
        expect(rule).to have_key('seq')
        expect(rule).to have_key('prefix')
        expect(rule).to have_key('action')
      end
    end

    let(:values) do
      [
        {
          'seq' => '10',
          'action' => 'permit',
          'prefix' => '1.2.3.0/24'
        },
        {
          'seq' => '20',
          'action' => 'permit',
          'prefix' => '2.3.4.0/24 le 30'
        },
        {
          'seq' => '30',
          'action' => 'deny',
          'prefix' => '3.4.5.0/24 ge 26 le 30'
        },
        {
          'seq' => '40',
          'action' => 'permit',
          'prefix' => '5.6.7.16/28 eq 29'
        }
      ]
    end

    it 'returns the correct values for all the keys' do
      expect(prefixlist).to eq(values)
    end
  end

  describe '#getall' do
    let(:del_pref_lists) {
      subject.getall.keys.map { |k| "no ip prefix-list #{k}" } 
    }

    before do
      node.config(del_pref_lists + 
                  ['ip prefix-list test1 seq 10 permit 1.2.3.0/24',
                  'ip prefix-list test1 seq 20 permit 2.3.4.0/24 le 30',
                  'ip prefix-list test1 seq 30 deny 3.4.5.0/24 ge 26 le 30',
                  'ip prefix-list test1 permit 5.6.7.8/28',
                  'ip prefix-list test2 seq 10 permit 10.11.0.0/16',
                  'ip prefix-list test2 seq 20 permit 10.12.0.0/16 le 24',
                  'ip prefix-list test3 permit 10.13.0.0/16'])
    end
    let(:prefixlists) { subject.getall }

    it 'returns the collection as hash' do
      expect(prefixlists).to be_a_kind_of(Hash)
    end

    it 'returns all prefix lists as array' do
      expect(prefixlists).to all ( be_an(Array) )
    end

    it 'has three prefix lists' do
      expect(prefixlists.size).to eq(3)
    end
  end

  describe '#create' do
    before do
      node.config('no ip prefix-list test4')
    end

    it 'creates a new prefix list' do
      expect(subject.get('test4')).to eq(nil)
      expect(subject.create('test4')).to be_truthy
      expect(subject.get('test4')).to eq([])
      expect(subject.get('test4').size).to eq(0)
    end
  end

  describe '#add_rule' do
    before do
      node.config(['no ip prefix-list test5',
                    'ip prefix-list test5'])
    end

    it 'adds rule to an existing prefix list' do
      expect(subject.get('test5')).to eq([])
      expect(subject.add_rule('test5', 'permit', '1.1.1.0/24')).to be_truthy
      expect(subject.get('test5')).to eq([{
                                        "seq" => "10",
                                        "action" => "permit",
                                        "prefix" => "1.1.1.0/24"}])
    end

    it 'adds rule to a non-existent prefix list' do
      expect(subject.get('test6')).to eq(nil)
      expect(subject.add_rule('test6', 'deny', '2.2.2.0/24')).to be_truthy
      expect(subject.get('test6')).to eq([{
                                      "seq" => "10",
                                      "action" => "deny",
                                      "prefix" => "2.2.2.0/24"}])
    end
  end

  describe '#delete' do
    before do
      node.config(['no ip prefix-list test7',
                  'no ip prefix-list test8',
                  'ip prefix-list test7',
                  'seq 10 permit 7.7.0.0/16',
                  'ip prefix-list test8',
                  'seq 10 permit 8.8.0.0/16',
                  'deny 9.9.0.0/16 le 24'])
    end

    it 'delets a prefix list' do
      expect(subject.get('test7')).to be_truthy
      expect(subject.delete('test7')).to be_truthy
      expect(subject.get('test7')).to eq(nil)
    end

    it 'deletes a rule in the prefix list' do
      expect(subject.get('test8')).to be_truthy
      expect(subject.delete('test8', 20)).to be_truthy
      expect(subject.get('test8').size).to eq(1)
      expect(subject.get('test8')[1]).to eq(nil)
    end
  end
end