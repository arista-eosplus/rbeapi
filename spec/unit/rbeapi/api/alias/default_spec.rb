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

require 'rbeapi/api/alias'

include FixtureHelpers

describe Rbeapi::Api::Alias do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    { name: 'Alias1',
      command: 'my command'
    }
  end
  let(:name) { test[:name] }

  def aliases
    aliases = Fixtures[:alias]
    return aliases if aliases
    fixture('alias', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(aliases)
  end

  describe '#getall' do
    let(:test1_entries) do
      { 'Alias1' => { name: 'Alias1', command: 'my command' },
        'Alias2' => { name: 'Alias2', command: 'my command 2' },
        'Alias3' => { name: 'Alias3', command: 'my command 3' }
      }
    end

    it 'returns the alias collection' do
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
    it 'returns the alias resource for given name' do
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
    it 'create a new alias entry' do
      expect(node).to receive(:config).with('alias Alias1 my command')
      expect(subject.create('Alias1', command: 'my command')).to be_truthy
    end
    it 'raises ArgumentError for create without required args ' do
      expect { subject.create('Alias') }.to \
        raise_error ArgumentError
    end
  end

  describe '#set_command' do
    it 'set the command' do
      expect(node).to receive(:config).with('alias Alias4 my command')
      expect(subject.create('Alias4', command: 'my command')).to be_truthy
    end
  end

  describe '#delete' do
    it 'delete a alias resource' do
      expect(node).to receive(:config).with('no alias Alias1')
      expect(subject.delete('Alias1')).to be_truthy
    end
  end

end
