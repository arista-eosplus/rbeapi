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

describe Rbeapi::Api::Aaa do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  let(:test) do
    {
      groups: {
        'blah' => {
          type: 'radius',
          servers: []
        },
        'blahtwo' => {
          type: 'radius',
          servers: []
        }
      }
    }
  end

  describe '#get' do
    before do
      node.config(['no aaa group server radius blah',
                   'no aaa group server radius blahtwo',
                   'aaa group server radius blah', 'exit',
                   'aaa group server radius blahtwo', 'exit'])
    end

    it 'returns the resource for given name' do
      expect(subject.get).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get[:groups].size).to eq(2)
    end
  end

  describe '#groups' do
    it 'returns new node instance' do
      expect(subject.groups).to be_a_kind_of(Rbeapi::Api::AaaGroups)
    end

    it 'returns a hash' do
      expect(subject.groups).to be_a_kind_of(Object)
    end
  end
end
