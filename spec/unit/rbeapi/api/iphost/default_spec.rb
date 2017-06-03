#
# Copyright (c) 2017, Arista Networks, Inc.
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

require 'rbeapi/api/iphosts'

include FixtureHelpers

describe Rbeapi::Api::Iphosts do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    {
      name: 'test1',
      ipaddress: ['192.168.0.1']
    }
  end
  let(:name) { test[:name] }

  def iphosts
    iphosts = Fixtures[:iphosts]
    return iphosts if iphosts
    fixture('iphosts', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(iphosts)
  end

  describe '#getall' do
    let(:test1_entries) do
      {
        'test1' => { name: 'test1', ipaddress: ['192.168.0.1'] },
        'test2' => { name: 'test2', ipaddress: ['10.0.0.1', '10.0.1.1'] },
        'test3.domain' => { name: 'test3.domain', ipaddress: ['172.16.0.1'] }
      }
    end

    it 'returns the ip host collection' do
      expect(subject.getall).to include(test1_entries)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has three entries' do
      expect(subject.getall.size).to eq(3)
    end
  end

  describe '#get' do
    it 'returns the ip host resource for given name' do
      expect(subject.get(name)).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get(name)).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get(name).size).to eq(2)
    end
  end

  describe '#create' do
    it 'create a new ip host entry' do
      expect(node).to receive(:config).with('ip host test 172.16.10.1')
      expect(subject.create('test', ipaddress: ['172.16.10.1'])).to be_truthy
    end
    it 'raises ArgumentError for create without required args ' do
      expect { subject.create('rbeapi') }.to \
        raise_error ArgumentError
    end
    it 'raises ArgumentError for invalid ipaddress value' do
      expect { subject.create('name', ipaddress: 'bogus') }.to \
        raise_error ArgumentError
    end
  end

  describe '#delete' do
    it 'delete a ip host resource' do
      expect(node).to receive(:config).with('no ip host test12')
      expect(subject.delete('test12')).to be_truthy
    end
  end

  describe '#set_ipaddress' do
    it 'set the ipaddress' do
      expect(node).to receive(:config).with('ip host test 172.16.10.1')
      expect(subject.create('test', ipaddress: ['172.16.10.1'])).to be_truthy
    end
  end
end
