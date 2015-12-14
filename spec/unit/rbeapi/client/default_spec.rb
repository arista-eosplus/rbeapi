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

include FixtureHelpers

describe Rbeapi::Client do
  subject { described_class }

  let(:node) { double('node') }

  def dut_conf
    fixture_file('dut.conf')
  end

  def test_conf
    fixture_file('test.conf')
  end

  let(:dut) do
    File.read(dut_conf)
  end

  let(:test) do
    File.read(test_conf)
  end

  let(:veos01) do
    {
      'username' => 'eapi',
      'password' => 'password',
      'transport' => 'http',
      'host' => 'veos01'
    }
  end

  # Client class methods
  describe '#config_for' do
    it 'returns the configuration options for the connection' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config_for('veos01')).to eq(veos01)
    end
  end

  describe '#connect_to' do
    it 'retrieves the node config' do
      expect(subject.connect_to('veos01')).to be_truthy
    end
  end

  describe '#load_config' do
    it 'overrides the default conf file loaded in the config' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config_for('dut')).to eq(nil)
      expect(subject.config_for('veos01')).to eq(veos01)
    end
  end

  # Config class methods
  describe 'config' do
    it 'gets the loaded configuration file data' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config.to_s).to eq(test)
    end
  end

  describe '#read' do
    it 'read the specified filename and load it' do
      expect(subject.load_config(dut_conf)).to eq(transport: 'socket')
      expect(subject.config.read(test_conf)).to eq(nil)
      expect(subject.config.to_s).to eq(test)
    end
  end

  describe '#get_connection' do
    it 'get connection dut' do
      expect(subject.config.get_connection('veos01')).to eq(veos01)
    end
  end

  describe '#reload' do
    it 'reloads the configuration file' do
      expect(subject.config.get_connection('veos01')).to eq(veos01)
      expect(subject.config.reload(filename: [dut_conf]))
        .to eq(transport: 'socket')
      expect(subject.config.get_connection('veos01')).to eq(nil)
      expect(subject.config.get_connection('dut')).not_to be_nil
    end
  end

  describe '#add_connection' do
    it 'adds a new connection section' do
      expect(subject.config.add_connection('test2',
                                           username: 'test2',
                                           password: 'test',
                                           transport: 'http',
                                           host: 'test2'
                                          )).to eq(username: 'test2',
                                                   password: 'test',
                                                   transport: 'http',
                                                   host: 'test2')
      expect(subject.config.get_connection('test2'))
        .to eq(username: 'test2',
               password: 'test',
               transport: 'http',
               host: 'test2')
    end
  end

  # Node Class Methods
  describe '#running_config' do
    it 'gets the nodes running config' do
      allow(node).to receive(:running_config).and_return(test)
      expect(node).to receive(:running_config)
      expect(node.running_config.to_s).to eq(test)
    end
  end

  describe '#startup_config' do
    it 'gets the nodes startup-configuration' do
      allow(node).to receive(:startup_config).and_return(test)
      expect(node).to receive(:startup_config)
      expect(node.startup_config).to eq(test)
    end
  end

  describe '#enable_authentication' do
    it 'gets the nodes startup-configuration' do
      expect(node).to receive(:enable_authentication).with('newpassword')
      expect(node.enable_authentication('newpassword')).to eq(nil)
    end
  end

  describe '#config' do
    it 'puts switch into config mode' do
      expect(node).to receive(:config)
        .with(['no ip virtual-router mac-address'])
      expect(node.config(['no ip virtual-router mac-address'])).to eq(nil)
    end

    it 'puts switch into config mode with options' do
      expect(node).to receive(:config)
        .with(['no ip virtual-router mac-address'],
              encoding: 'json',
              open_timeout: 27.00,
              read_timeout: 27.00)
      expect(node.config(['no ip virtual-router mac-address'],
                         encoding: 'json',
                         open_timeout: 27.00,
                         read_timeout: 27.00)).to eq(nil)
    end
  end

  describe '#enable' do
    it 'puts the switch into privilege mode' do
      expect(node).to receive(:enable).with('show hostname', encoding: 'text')
      expect(node.enable('show hostname', encoding: 'text'))
        .to eq(nil)
    end
  end

  describe '#run_commands' do
    it 'send commands to node' do
      expect(node).to receive(:run_commands)
        .with('show hostname', encoding: 'text')
      expect(node.run_commands('show hostname', encoding: 'text'))
        .to eq(nil)
    end
  end

  describe '#get_config' do
    it 'will retrieve the specified configuration' do
      expect(node).to receive(:get_config)
        .with(config: 'running-config')
      expect(node.get_config(config: 'running-config'))
        .to eq(nil)
    end

    it 'will retrieve the specified configuration with param' do
      expect(node).to receive(:get_config)
        .with(config: 'running-config', param: 'all')
      expect(node.get_config(config: 'running-config', param: 'all'))
        .to eq(nil)
    end
  end

  describe '#api' do
    it 'returns api module' do
      expect(node).to receive(:api).with('vlans')
      expect(node.api('vlans')).to eq(nil)
    end
  end

  describe '#refresh' do
    it 'refreshes configs for next call' do
      expect(node).to receive(:refresh)
      expect(node.refresh).to eq(nil)
    end
  end
end
