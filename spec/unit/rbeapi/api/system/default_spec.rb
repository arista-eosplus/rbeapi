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

require 'rbeapi/api/system'

include FixtureHelpers

describe Rbeapi::Api::System do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:test) do
    { hostname: 'localhost', iprouting: true }
  end

  def system
    system = Fixtures[:system]
    return system if system
    fixture('system', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(system)
  end

  describe '#get' do
    it 'returns the username collection' do
      expect(subject.get).to include(test)
    end

    it 'returns a hash collection' do
      expect(subject.get).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get.size).to eq(2)
    end
  end

  describe '#set_hostname' do
    it 'sets the hostname' do
      expect(node).to receive(:config).with('hostname localhost')
      expect(subject.set_hostname(value: 'localhost')).to be_truthy
      expect(subject.get[:hostname]).to eq('localhost')
    end
  end

  describe '#set_iprouting' do
    it 'sets ip routing default true' do
      expect(node).to receive(:config).with('default ip routing')
      expect(subject.set_iprouting(default: true)).to be_truthy
    end

    it 'sets ip routing default false' do
      expect(node).to receive(:config).with('ip routing')
      expect(subject.set_iprouting(default: false)).to be_truthy
      expect(subject.get[:iprouting]).to eq(true)
    end

    it 'sets ip routing enable true' do
      expect(node).to receive(:config).with('ip routing')
      expect(subject.set_iprouting(enable: true)).to be_truthy
      expect(subject.get[:iprouting]).to eq(true)
    end

    it 'sets ip routing enable false' do
      expect(node).to receive(:config).with('no ip routing')
      expect(subject.set_iprouting(enable: false)).to be_truthy
    end
  end
end
