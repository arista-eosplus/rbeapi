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
require 'rbeapi/api/alias'

describe Rbeapi::Api::Alias do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  let(:command) do
    'my command'
  end

  let(:test) do
    { name: 'test1',
      command: 'my command'
    }
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    let(:test1_entries) do
      { 'test1' => { name: 'test1', command: 'my command' },
        'test2' => { name: 'test2', command: 'my command 2' },
        'test3' => { name: 'test3', command: 'my command 3' }
      }
    end

    before do
      node.config(['no alias test1',
                   'no alias test2',
                   'no alias test3.domain',
                   'alias test1 my command',
                   'alias test2 my command 2',
                   'alias test3 my command 3'])
    end

    it 'returns the alias collection' do
      expect(subject.getall).to include(test1_entries)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'returns the alias resources for given host' do
      expect(subject.get('test1')).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get('test1')).to be_a_kind_of(Hash)
    end

    it 'has 2 entries' do
      expect(subject.get('test1').size).to eq(2)
    end
  end

  describe '#create' do
    before do
      node.config(['no alias test1'])
    end

    it 'create a new alias name' do
      expect(subject.get('test1')).to eq(nil)
      expect(subject.create('test1', command: 'my command')).to be_truthy
      expect(subject.get('test1')[:command]).to eq('my command')
    end

    it 'raises ArgumentError for create without required args ' do
      expect { subject.create('test1') }.to \
        raise_error ArgumentError
    end

  end

  describe '#delete' do
    before do
      node.config(['alias test12 a command'])
    end

    it 'delete an alias resource' do
      expect(subject.get('test12')[:name]).to eq('test12')
      expect(subject.delete('test12')).to be_truthy
      expect(subject.get('test12')).to eq(nil)
    end
  end

  describe '#set_command' do
    before do
      node.config(['no alias test13'])
    end

    it 'change the command alias' do
      expect(subject.create('test13', command: 'my command')).to be_truthy
      expect(subject.create('test13', command: 'my command 2')).to be_truthy
      expect(subject.get('test13')[:command]).to eq('my command 2')
    end

  end

end
