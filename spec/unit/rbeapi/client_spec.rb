require 'spec_helper'
require 'rbeapi/client'

describe Rbeapi::Client do

  describe '#config' do
    subject { described_class.config }
    it { is_expected.to be_a_kind_of Rbeapi::Client::Config }
  end

end

describe Rbeapi::Client::Config do

  describe '#initialize' do
    subject { described_class.new }
    it { is_expected.to be_a_kind_of Rbeapi::Client::Config }
  end

end


describe Rbeapi::Client::Node do

  let(:connection) { double }
  let(:instance) { described_class.new(connection) }

  context 'retrieve config' do
    before :each do
      allow(connection).to receive(:execute)
        .with(commands, format: 'text')
        .and_return(response)
    end

    describe 'retrieve running_config' do
      subject { instance.running_config }

      let(:commands) { ['enable', 'show running-config all'] }
      let(:response) { [{}, {'output' => '!running-config'}] }

      it { is_expected.to eq('!running-config') }
    end

    describe '.startup_config' do
      subject { instance.startup_config }

      let(:commands) { ['enable', 'show startup-config '] }
      let(:response) { [{}, {'output' => '!startup-config'}] }

      it { is_expected.to eq('!startup-config') }
    end
  end

  describe '#make_response' do
    subject { instance.send(:make_response, *args) }

    let(:cmds) { 'show version' }
    let(:resp) { 'version' }
    let(:enc) { 'json' }
    let(:args) { [cmds, resp, enc] }

    it {is_expected.to eq(command: 'show version', response: 'version',
                          encoding: 'json') }
  end

  describe '#enable_authentication' do
    it 'sets the enablepwd = password' do
      expect(instance.instance_variable_get(:@enablepwd)).not_to eq('password')
      instance.enable_authentication('password')
      expect(instance.instance_variable_get(:@enablepwd)).to eq('password')
    end
  end

  context 'with #config' do
    subject { instance.config(args) }

    before :each do
      allow(connection).to receive(:execute)
        .with(commands, format: 'json')
        .and_return(response)
    end

    let :response do
      resp = []
      commands.length.times { resp << {} }
      resp
    end

    describe 'when sending a single command' do
      let(:commands) { ['enable', 'configure', 'hostname foo'] }
      let(:args) { 'hostname foo' }

      it { is_expected.to eq([{}]) }
    end

    describe 'when sending multiple commands' do
      let(:args) { ['hostname foo', 'hostname bar'] }

      let :commands do
        ['enable', 'configure', 'hostname foo', 'hostname bar']
      end

      it { is_expected.to eq([{}, {}]) }
    end
  end

  describe '#refresh' do
    it 'clears the memozied instance variables' do
      instance.instance_variable_set(:@running_config, 'running_config')
      instance.instance_variable_set(:@startup_config, 'startup_config')

      instance.refresh

      expect(instance.instance_variable_get(:@running_config)).to be_nil
      expect(instance.instance_variable_get(:@startup_config)).to be_nil
    end
  end

  context 'with #enable' do
    subject { instance.enable(args, opts) }

    before :each do
      allow(connection).to receive(:execute)
        .with(any_args())
        .and_return(response)
    end

    let(:format) { 'json' }
    let(:opts) { {strict: false, encoding: 'json'} }

    let :response do
      resp = []
      commands.length.times { resp << {} }
      resp
    end

    describe 'when sending a single command  with defaults' do
      let(:commands) { ['enable', 'show version'] }
      let(:args) { 'show version' }

      it { is_expected.to eq([{command: 'show version', response: {},
                               encoding: 'json'}]) }
    end

    describe 'when sending multiple commands (strict=true)' do
      let(:commands) { ['enable', 'show version' , 'show hostname'] }
      let(:args) { ['show version', 'show hostname'] }
      let(:opts) { {strict: true} }

      it { is_expected.to eq([{command: 'show version', response: {},
                               encoding: 'json'},
                              {command: 'show hostname',
                               response: {}, encoding: 'json'}]) }
    end

    describe 'when sending multiple commands (strict=false)' do
      let(:commands) { ['show version', 'show hostname'] }
      let(:args) { ['show version', 'show hostname'] }

      it { is_expected.to eq([{command: 'show version', response: {},
                               encoding: 'json'},
                              {command: 'show hostname',
                               response: {}, encoding: 'json'}]) }
    end
  end
end

