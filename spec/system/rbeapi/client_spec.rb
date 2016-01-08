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

describe Rbeapi::Client do
  subject { described_class }

  def dut_conf
    fixture_file('dut.conf')
  end

  def test_conf
    fixture_file('test.conf')
  end

  let(:node) do
    subject.config.read(fixture_file('dut.conf'))
    subject.connect_to('dut')
  end

  let(:dut) do
    File.read(dut_conf)
  end

  let(:test) do
    File.read(test_conf)
  end

  let(:enablepwd) { 'enable_admin' }

  let(:veos01) do
    {
      'username' => 'eapi',
      'password' => 'password',
      'transport' => 'http',
      'host' => 'veos01'
    }
  end

  let(:veos05) do
    {
      'host' => '172.16.131.40',
      'username' => 'admin',
      'password' => 'admin',
      'enablepwd' => 'password',
      'transport' => 'https',
      'port' => 1234,
      'open_timeout' => 12,
      'read_timeout' => 12
    }
  end

  let(:test_data) do
    [
      '[connection:veos01]',
      '[connection:veos02]',
      '[connection:veos03',
      '[connection:veos04]',
      '[connection:veos05]',
      '[connection: localhost]',
      'username',
      'password',
      'transport',
      'host'
    ]
  end

  # Client class methods
  describe '#config_for' do
    it 'returns the configuration options for the connection' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config_for('veos01')).to eq(veos01)
    end

    it 'returns nil if connection does not exist' do
      expect(subject.config_for('veos22')).to eq(nil)
    end
  end

  describe '#connect_to' do
    it 'retrieves the node config' do
      expect(subject.connect_to('veos01')).to be_truthy
    end

    it 'returns nil if connection does not exist' do
      expect(subject.connect_to('veos22')).to eq(nil)
    end
  end

  describe '#load_config' do
    it 'overrides the default conf file loaded in the config' do
      expect(subject.load_config(test_conf)).to eq(nil)
    end

    it 'returns nil if connection does not exit' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config_for('dut')).to eq(nil)
    end

    it 'returns conf settings if connection exists' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config_for('veos01')).to eq(veos01)
    end
  end

  # Config class methods
  describe 'config' do
    it 'gets the loaded configuration file data' do
      expect(subject.load_config(test_conf)).to eq(nil)
      expect(subject.config.to_s).to include(test_data[0])
    end
  end

  describe '#read' do
    it 'read the specified filename and load dut' do
      expect(subject.config.read(dut_conf)).to eq(transport: 'socket')
      expect(subject.config.to_s)
        .to include('host', 'username', 'password', '[connection:dut]')
    end

    it 'read the specified filename and load test' do
      expect(subject.config.read(test_conf)).to eq(nil)
      expect(subject.config.to_s).to include(test_data[0])
    end
  end

  describe '#get_connection' do
    it 'get connection veos01' do
      expect(subject.config.get_connection('veos01')).to eq(veos01)
    end

    it 'get connection veos05' do
      expect(subject.config.get_connection('veos05')).to eq(veos05)
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
  describe 'node' do
    it 'retrieves the node' do
      expect(node).to be_kind_of(Rbeapi::Client::Node)
    end
  end

  describe '#running_config' do
    it 'gets the nodes running config' do
      expect(node.running_config).to be_truthy
    end

    it 'expects running config to return a string' do
      expect(node.running_config).to be_kind_of(String)
    end
  end

  describe '#startup_config' do
    it 'gets the nodes startup-configuration' do
      expect(node.startup_config).to be_truthy
    end

    it 'expects startup-configuration to be a string' do
      expect(node.startup_config).to be_kind_of(String)
    end
  end

  describe '#enable_authentication' do
    it 'gets the nodes startup-configuration' do
      expect(node.enable_authentication('newpassword')).to eq('newpassword')
    end
  end

  describe '#config' do
    it 'puts switch into config mode' do
      expect(node.config(['no ip virtual-router mac-address']))
        .to be_truthy
    end

    it 'expects config to return array' do
      expect(node.config(['no ip virtual-router mac-address']))
        .to be_kind_of(Array)
    end

    it 'puts switch into config mode with options and returns array' do
      expect(node.config(['no ip virtual-router mac-address'],
                         encoding: 'json',
                         open_timeout: 27.00,
                         read_timeout: 27.00))
        .to be_kind_of(Array)
    end

    describe 'set dry run' do
      before do
        # Prevents puts from writing to console
        allow($stdout).to receive(:puts)
        node.dry_run = true
      end

      it 'expects config to do dry run' do
        expect(node.config(['no ip virtual-router mac-address']))
          .to eq(nil)
      end
    end

    it 'returns error if invalid command' do
      expect { node.config(['no ip virtual-router mac-addresses']) }
        .to raise_error Rbeapi::Eapilib::CommandError
    end
  end

  describe '#enable' do
    it 'puts the switch into privilege mode' do
      expect(node.enable('show hostname')[0][:result])
        .to include('fqdn', 'hostname')
    end

    it 'puts the switch into privilege mode with encoding' do
      expect(node.enable('show hostname', encoding: 'text')[0][:encoding])
        .to eq('text')
    end

    it 'puts the switch into privilege mode with strict option' do
      expect(node.enable('show hostname', strict: true)[0])
        .to include(:command, :result, :encoding)
    end

    it 'puts the switch into privilege mode with read and open timeout' do
      expect(node.enable('show hostname',
                         open_timeout: 29,
                         read_timeout: 29)[0]).to include(:command,
                                                          :result,
                                                          :encoding)
    end

    it 'raises invalid command error' do
      expect { node.enable(['show hostname', 'do this thing']) }
        .to raise_error Rbeapi::Eapilib::CommandError
    end
  end

  describe '#run_commands' do
    it 'expects run_commands to be a string' do
      expect(node.run_commands('show hostname', encoding: 'text')[0]['output'])
        .to be_kind_of String
    end

    it 'sends commands to node with encoding' do
      expect(node.run_commands('show hostname', encoding: 'text')[0]['output'])
        .to include('FQDN:', 'Hostname:')
    end

    it 'sends commands with open and read timeout' do
      expect(node.run_commands('show hostname',
                               open_timeout: 26,
                               read_timeout: 26)[0]).to include('fqdn',
                                                                'hostname')
    end

    it 'expects run_commands to raise a command error' do
      expect { node.run_commands('do this thing') }
        .to raise_error Rbeapi::Eapilib::CommandError
    end
  end

  describe '#run_commands with enable password' do
    # Before the tests Set the enable password on the dut
    before(:each) { node.config(["enable secret 0 #{enablepwd}"]) }

    # After the tests clear the enable password on the dut
    after(:each) { node.config(['no enable secret']) }

    it 'sends commands with enablepwd set' do
      expect(node.enable_authentication(enablepwd)).to eq(enablepwd)
      expect(node.run_commands('show hostname')).to be_truthy
    end
  end

  describe '#get_config' do
    it 'will retrieve the specified configuration and return array' do
      expect(node.get_config(config: 'running-config'))
        .to be_kind_of(Array)
    end

    it 'will retrieve with param and return array' do
      expect(node.get_config(config: 'running-config', param: 'all'))
        .to be_kind_of(Array)
    end

    it 'raises invalid command error' do
      expect { node.get_config(config: 'running-configurations') }
        .to raise_error Rbeapi::Eapilib::CommandError
    end
  end

  describe '#api' do
    it 'returns api module' do
      expect(node.api('vlans')).to be_kind_of(Rbeapi::Api::Vlans)
    end

    it 'returns error if invalid name' do
      expect { node.api('vlanss') }.to raise_error
    end
  end

  describe '#refresh' do
    it 'refreshes configs for next call' do
      expect(node.refresh).to eq(nil)
    end
  end
end
