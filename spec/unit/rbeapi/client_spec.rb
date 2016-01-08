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

  def dut_conf
    fixture_file('dut.conf')
  end

  def test_conf
    fixture_file('test.conf')
  end

  def empty_conf
    fixture_file('empty.conf')
  end

  def yaml_conf
    fixture_file('eapi.conf.yaml')
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
      '[connection:veos01]'
    ]
  end

  let(:default_entry) { "[connection:localhost]\ntransport : socket\n" }

  # Client class methods
  describe '#config_for' do
    # Verify that the EAPI_CONF env variable path is used by default
    # when the Config class is instantiated/reload-ed.
    it 'env path to config file' do
      # Store env path for the eapi conf file and reload the class
      conf = fixture_dir + '/env_path.conf'
      ENV.store('EAPI_CONF', conf)
      subject.config.reload

      # Verify env_path.conf file was loaded
      expect(subject.config.to_s).to include('[connection:env_path]')
    end

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
      expect(subject.config.to_s).to include(test_data[0])
    end

    it 'loading empty config file does not fail' do
      expect(subject.load_config(empty_conf)).to eq(nil)
      expect(subject.config.to_s).to eq(default_entry)
    end

    it 'does not load bad config file data' do
      expect(subject.load_config(yaml_conf)).to eq(nil)
      expect(subject.config.to_s).to eq('')
    end
  end

  describe '#read' do
    it 'read the specified filename and load it' do
      expect(subject.load_config(dut_conf)).to eq(nil)
      expect(subject.config.read(test_conf)).to eq(nil)
      expect(subject.config.to_s).to include(test_data[0])
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
      expect(subject.config.reload(filename: [dut_conf])).to eq(nil)
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
                                          )).to eq(nil)
      expect(subject.config.get_connection('test2'))
        .to eq(username: 'test2',
               password: 'test',
               transport: 'http',
               host: 'test2')
    end
  end
end
