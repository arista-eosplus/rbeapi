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

  # Client class methods
  describe '#connect_to' do
    it 'retrieves the node config' do
      expect(node).not_to be_nil
    end
  end

  describe '#config' do
    it 'returns the currently loaded config object' do
      expect(subject.config.read(dut_conf))
        .not_to be_nil
      expect(subject.connect_to('dut')).not_to be_nil
    end
  end

  describe '#config_for' do
    it 'returns the configuration options for the connection' do
      expect(subject.config_for('dut')).not_to be_nil
    end
  end

  describe '#load_config' do
    it 'overrides the default conf file loaded in the config' do
      expect(subject.load_config(test_conf))
        .to eq(nil)
      expect(subject.config_for('dut')).to eq(nil)
      expect(subject.config_for('veos01'))
        .to eq('username' => 'eapi',
               'password' => 'password',
               'transport' => 'http',
               'host' => 'veos01')
    end
  end

  # Config class methods
  describe 'config' do
    it 'gets the loaded configuration file data' do
      expect(subject.config).not_to be_nil
    end
  end

  describe '#read' do
    it 'read the specified filename and load it' do
      expect(subject.config.read(dut_conf))
        .to eq(transport: 'socket')
    end
  end

  describe '#get_connection' do
    it 'get connection dut' do
      expect(subject.config.get_connection('dut')).not_to be_nil
    end
  end

  describe '#reload' do
    it 'reloads the configuration file' do
      expect(subject.config.reload(filename: [dut_conf]))
        .to eq(transport: 'socket')
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
    end
  end

  # Node Class Methods
  describe '#running_config' do
    it 'gets the nodes running config' do
      expect(node.running_config).not_to be_nil
    end
  end

  describe '#startup_config' do
    it 'gets the nodes startup-configuration' do
      expect(node.startup_config).not_to be_nil
    end
  end

  describe '#enable_authentication' do
    it 'gets the nodes startup-configuration' do
      expect(node.enable_authentication('password')).to eq('password')
    end
  end

  describe '#config' do
    it 'puts switch into config mode' do
      expect(node.config(['no ip virtual-router mac-address'])).to be_truthy
    end

    it 'puts switch into config mode with options' do
      expect(node.config(['no ip virtual-router mac-address'],
                         encoding: 'json',
                         open_timeout: 27.00,
                         read_timeout: 27.00)).to be_truthy
    end
  end

  describe '#enable' do
    it 'puts the switch into privilege mode' do
      expect(node.enable('show hostname', encoding: 'text')[0])
        .to include(:command, :result, :encoding)
    end
  end

  describe '#run_commands' do
    it 'send commands to node' do
      expect(node.run_commands('show hostname', encoding: 'text')[0])
        .to include('output')
    end
  end

  describe '#api' do
    it 'returns api module' do
      expect(node.api('vlans')).not_to be_nil
    end
  end

  describe '#refresh' do
    it 'refreshes configs for next call' do
      expect(node.refresh).to eq(nil)
    end
  end
end
