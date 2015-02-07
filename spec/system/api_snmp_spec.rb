require 'spec_helper'
require 'rbeapi/client'


describe Rbeapi::Client do
  let(:node) { described_class.connect_to('veos01') }
  let(:api) { node.api('snmp') }

  let(:entity) do
    { 'location' => '', 'contact' => '', 'chassis_id' => '',
      'source_interface' => '' }
  end

  context '#get' do
    subject { api.get }

    describe 'returns the snmp config' do
      before { node.config(['no snmp-server contact',
                            'no snmp-server location',
                            'no snmp-server chassis-id',
                            'no snmp-server source-interface']) }

      it { is_expected.to eq(entity) }
    end
  end

  context '#set_contact' do
    subject { api.set_contact(opts) }

    before { node.config([*setup]) }

    describe "configures the snmp contact" do
      let(:opts) { {value: 'foo'} }
      let(:setup) { 'default snmp-server contact' }

      it 'sets the value to foo' do
        expect(api.get['contact']).to eq ''
        subject
        expect(api.get['contact']).to eq 'foo'
      end
    end

    describe "negates the snmp contact" do
      let(:opts) { {} }
      let(:setup) { 'snmp-server contact foo' }

      it 'removes the value' do
        expect(api.get['contact']).to eq 'foo'
        subject
        expect(api.get['contact']).to eq ''
      end
    end

    describe "defaults the snmp contact" do
      let(:opts) { {default: true} }
      let(:setup) { 'snmp-server contact foo' }

      it 'removes the value' do
        expect(api.get['contact']).to eq 'foo'
        subject
        expect(api.get['contact']).to eq ''
      end
    end

    describe "default overrides value in opts" do
      let(:opts) { {value: 'bar', default: true} }
      let(:setup) { 'snmp-server contact foo' }

      it 'removes the value' do
        expect(api.get['contact']).to eq 'foo'
        subject
        expect(api.get['contact']).to eq ''
      end
    end
  end

  context '#set_location' do
    subject { api.set_location(opts) }

    before { node.config([*setup]) }

    describe "configures the snmp location" do
      let(:opts) { {value: 'foo'} }
      let(:setup) { 'default snmp-server location' }

      it 'sets the value to foo' do
        expect(api.get['location']).to eq ''
        subject
        expect(api.get['location']).to eq 'foo'
      end
    end

    describe "negates the snmp location" do
      let(:opts) { {} }
      let(:setup) { 'snmp-server location foo' }

      it 'removes the value' do
        expect(api.get['location']).to eq 'foo'
        subject
        expect(api.get['location']).to eq ''
      end
    end

    describe "defaults the snmp location" do
      let(:opts) { {default: true} }
      let(:setup) { 'snmp-server location foo' }

      it 'removes the value' do
        expect(api.get['location']).to eq 'foo'
        subject
        expect(api.get['location']).to eq ''
      end
    end

    describe "default overrides value in opts" do
      let(:opts) { {value: 'bar', default: true} }
      let(:setup) { 'snmp-server location foo' }

      it 'removes the value' do
        expect(api.get['location']).to eq 'foo'
        subject
        expect(api.get['location']).to eq ''
      end
    end
  end

  context '#set_chassis_id' do
    subject { api.set_chassis_id(opts) }

    before { node.config([*setup]) }

    describe "configures the snmp chassis-id" do
      let(:opts) { {value: 'foo'} }
      let(:setup) { 'default snmp-server chassis-id' }

      it 'sets the value to foo' do
        expect(api.get['chassis_id']).to eq ''
        subject
        expect(api.get['chassis_id']).to eq 'foo'
      end
    end

    describe "negates the snmp chassis-id" do
      let(:opts) { {} }
      let(:setup) { 'snmp-server chassis-id foo' }

      it 'removes the value' do
        expect(api.get['chassis_id']).to eq 'foo'
        subject
        expect(api.get['chassis_id']).to eq ''
      end
    end

    describe "defaults the snmp chassis-id" do
      let(:opts) { {default: true} }
      let(:setup) { 'snmp-server chassis-id foo' }

      it 'removes the value' do
        expect(api.get['chassis_id']).to eq 'foo'
        subject
        expect(api.get['chassis_id']).to eq ''
      end
    end

    describe "default overrides value in opts" do
      let(:opts) { {value: 'bar', default: true} }
      let(:setup) { 'snmp-server chassis-id foo' }

      it 'removes the value' do
        expect(api.get['chassis_id']).to eq 'foo'
        subject
        expect(api.get['chassis_id']).to eq ''
      end
    end
  end

  context '#set_source_interface' do
    subject { api.set_source_interface(opts) }

    before { node.config([*setup]) }

    describe "configures the snmp source-interface" do
      let(:opts) { {value: 'Loopback0'} }
      let(:setup) { 'default snmp-server source-interface' }

      it 'sets the value to Loopback0' do
        expect(api.get['source_interface']).to eq ''
        subject
        expect(api.get['source_interface']).to eq 'Loopback0'
      end
    end

    describe "negates the snmp source-interface" do
      let(:opts) { {} }
      let(:setup) { 'snmp-server source-interface Loopback0' }

      it 'removes the value' do
        expect(api.get['source_interface']).to eq 'Loopback0'
        subject
        expect(api.get['source_interface']).to eq ''
      end
    end

    describe "defaults the snmp source-interface" do
      let(:opts) { {default: true} }
      let(:setup) { 'snmp-server source-interface Loopback0' }

      it 'removes the value' do
        expect(api.get['source_interface']).to eq 'Loopback0'
        subject
        expect(api.get['source_interface']).to eq ''
      end
    end

    describe "default overrides value in opts" do
      let(:opts) { {value: 'bar', default: true} }
      let(:setup) { 'snmp-server source-interface Loopback0' }

      it 'removes the value' do
        expect(api.get['source_interface']).to eq 'Loopback0'
        subject
        expect(api.get['source_interface']).to eq ''
      end
    end
  end

end

