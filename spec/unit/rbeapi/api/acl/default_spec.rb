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

require 'rbeapi/api/acl'

include FixtureHelpers

describe Rbeapi::Api::Acl do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def acls
    acls = Fixtures[:acls]
    return acls if acls
    fixture('acl_standard', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(acls)
  end

  describe '#get' do
    let(:test1_entries) do
      { '10' => { seqno: '10', action: 'permit', srcaddr: '1.2.3.4',
                  srcprefixlen: '255.255.255.255', log: 'log' },
        '20' => { seqno: '20', action: 'permit', srcaddr: '1.2.3.4',
                  srcprefixlen: '255.255.0.0', log: 'log' },
        '30' => { seqno: '30', action: 'deny', srcaddr: '0.0.0.0',
                  srcprefixlen: '255.255.255.255', log: nil },
        '40' => { seqno: '40', action: 'permit', srcaddr: '5.6.7.0',
                  srcprefixlen: '24', log: nil },
        '50' => { seqno: '50', action: 'permit', srcaddr: '16.0.0.0',
                  srcprefixlen: '8', log: nil },
        '60' => { seqno: '60', action: 'permit', srcaddr: '9.10.11.0',
                  srcprefixlen: '255.255.255.0', log: 'log' } }
    end

    it 'returns the ACL resource' do
      expect(subject.get('test1')).to eq(test1_entries)
    end
  end

  describe '#getall' do
    it 'returns the ACL collection' do
      expect(subject.getall).to include('test1')
      expect(subject.getall).to include('test2')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.getall.size).to eq(2)
    end
  end

  describe '#create' do
    it 'creates a new ACL resource' do
      expect(node).to receive(:config).with('ip access-list standard abc')
      expect(subject.create('abc')).to be_truthy
    end
  end

  describe '#delete' do
    it 'deletes an ACL resource' do
      expect(node).to receive(:config).with('no ip access-list standard abc')
      expect(subject.delete('abc')).to be_truthy
    end
  end

  describe '#default' do
    it 'sets ACL abc to default value' do
      expect(node).to receive(:config)
        .with('default ip access-list standard abc')
      expect(subject.default('abc')).to be_truthy
    end
  end

  describe '#update_entry' do
    let(:update_entry) do
      { seqno: '60', action: 'permit', srcaddr: '0.0.0.0',
        srcprefixlen: '255.255.255.255', log: nil }
    end

    let(:update_cmd) do
      ['ip access-list standard test2', 'no 60',
       '60 permit 0.0.0.0/255.255.255.255', 'exit']
    end

    it 'Change entry 60 to values in update_entry' do
      expect(subject.get('test2')['60'][:action]).to eq('deny')
      expect(node).to receive(:config).with(update_cmd)
      expect(subject.update_entry('test2', update_entry)).to be_truthy
    end
  end

  describe '#add_entry' do
    let(:new_entry) do
      { seqno: '90', action: 'deny', srcaddr: '1.2.3.0',
        srcprefixlen: '255.255.255.0', log: nil }
    end

    let(:new_cmd) do
      ['ip access-list standard test2', '90 deny 1.2.3.0/255.255.255.0',
       'exit']
    end

    it 'Add entry 90 to the test2 ACL' do
      expect(subject.get('test2')['90']).to be_falsy
      expect(node).to receive(:config).with(new_cmd)
      expect(subject.add_entry('test2', new_entry)).to be_truthy
    end
  end

  describe '#remove_entry' do
    let(:delete_cmd) do
      ['ip access-list standard test2', 'no 30', 'exit']
    end

    it 'Remove entry 30 from the test2 ACL' do
      expect(node).to receive(:config).with(delete_cmd)
      expect(subject.remove_entry('test2', '30')).to be_truthy
    end
  end
end
