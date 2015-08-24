require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/stp'

describe Rbeapi::Api::Stp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:resource) { subject.get }

    let(:keys) do
      [:interfaces, :instances, :mode]
    end

    it 'includes all required keys' do
      keys.each do |key|
        expect(subject.get).to include(key)
      end
    end
  end

  describe '#instances' do
    it 'is a kind of StpInstances' do
      expect(subject.instances).to be_a_kind_of(Rbeapi::Api::StpInstances)
    end
  end

  describe '#interfaces' do
    it 'is a kind of StpInterfaces' do
      expect(subject.interfaces).to be_a_kind_of(Rbeapi::Api::StpInterfaces)
    end
  end

  describe '#set_mode' do
    it 'sets the stp mode to mstp' do
      node.config('spanning-tree mode none')
      expect(subject.get[:mode]).to eq('none')
      expect(subject.set_mode(value: 'mstp')).to be_truthy
      expect(subject.get[:mode]).to eq('mstp')
    end

    it 'sets the stp mode to none' do
      node.config('spanning-tree mode mstp')
      expect(subject.get[:mode]).to eq('mstp')
      expect(subject.set_mode(value: 'none')).to be_truthy
      expect(subject.get[:mode]).to eq('none')
    end

    it 'negates the stp mode' do
      node.config('spanning-tree mode none')
      expect(subject.get[:mode]).to eq('none')
      expect(subject.set_mode(enable: false)).to be_truthy
      expect(subject.get[:mode]).to eq('mstp')
    end

    it 'defaults the stp mode' do
      node.config('spanning-tree mode none')
      expect(subject.get[:mode]).to eq('none')
      expect(subject.set_mode(default: true)).to be_truthy
      expect(subject.get[:mode]).to eq('mstp')
    end
  end
end
