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

require 'rbeapi/client'
require 'rbeapi/api/aaa'

describe Rbeapi::Api::AaaGroups do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  let(:all) do
    {
      'blah' => {
        type: 'radius',
        servers: []
      },
      'blahtwo' => {
        type: 'radius',
        servers: []
      }
    }
  end

  let(:blah) do
    {
      type: 'radius',
      servers: []
    }
  end

  let(:blahthree) do
    {
      type: 'tacacs+',
      servers: []
    }
  end

  let(:servers) do
    [{
      name: 'localhost',
      auth_port: '1812',
      acct_port: '1813'
    }]
  end

  describe '#get' do
    before do
      node.config(['no aaa group server radius blah',
                   'no aaa group server radius blahtwo',
                   'no aaa group server tacacs+ blahthree',
                   'aaa group server radius blah', 'exit',
                   'aaa group server radius blahtwo', 'exit'])
    end

    it 'returns the resource for given name' do
      expect(subject.get('blah')).to eq(blah)
    end
  end

  describe '#getall' do
    it 'returns all of the aaa group resources' do
      expect(subject.getall).to eq(all)
    end
  end

  describe '#create' do
    it 'adds a new aaa group' do
      expect(subject.create('blahthree', 'tacacs+')).to eq(true)
      expect(subject.get('blahthree')).to eq(blahthree)
    end
  end

  describe '#delete' do
    it 'removes specified aaa group' do
      expect(subject.get('blahthree')).to eq(blahthree)
      expect(subject.delete('blahthree')).to eq(true)
      expect(subject.get('blahthree')).to eq(nil)
    end
  end

  describe '#set_servers' do
    it 'removes all servers and then adds one' do
      expect(subject.set_servers('blahtwo', [{ name: 'localhost' }]))
        .to eq(true)
      expect(subject.get('blahtwo')[:servers]).to eq(servers)
    end
  end
end
