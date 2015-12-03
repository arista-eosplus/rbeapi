require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/vrrp'

describe Rbeapi::Api::Vrrp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  before :all do
    @sec_ips = ['1.2.3.1', '1.2.3.2', '1.2.3.3', '1.2.3.4']
    @tracks = [{ name: 'Ethernet3', action: 'decrement', amount: 33 },
               { name: 'Ethernet2', action: 'decrement', amount: 22 },
               { name: 'Ethernet2', action: 'shutdown' }]
  end

  describe '#get' do
    before do
      node.config(['no interface Vlan150', 'no interface Vlan100',
                   'interface Vlan100', 'interface Vlan150',
                   'ip address 40.10.5.8/24', 'vrrp 30 priority 100',
                   'vrrp 30 timers advertise 1',
                   'vrrp 30 mac-address advertisement-interval 30',
                   'no vrrp 30 preempt', 'vrrp 30 preempt delay minimum 0',
                   'vrrp 30 preempt delay reload 0', 'vrrp 30 delay reload 0',
                   'no vrrp 30 authentication', 'vrrp 30 ip 40.10.5.31',
                   'vrrp 30 ipv6 ::', 'vrrp 30 description The description',
                   'vrrp 30 shutdown', 'vrrp 30 track Ethernet1 decrement 5',
                   'no vrrp 30 bfd ip', 'no vrrp 30 bfd ipv6',
                   'vrrp 30 ip version 2', 'vrrp 40 priority 200',
                   'vrrp 40 timers advertise 1',
                   'vrrp 40 mac-address advertisement-interval 30',
                   'vrrp 40 preempt', 'vrrp 40 preempt delay minimum 0',
                   'vrrp 40 preempt delay reload 0', 'vrrp 40 delay reload 0',
                   'no vrrp 40 authentication', 'vrrp 40 ip 40.10.5.32',
                   'vrrp 40 ipv6 ::', 'no vrrp 40 description',
                   'no vrrp 40 shutdown',
                   'vrrp 40 track Ethernet3 decrement 33',
                   'vrrp 40 track Ethernet2 decrement 22',
                   'vrrp 40 track Ethernet2 shutdown', 'no vrrp 40 bfd ip',
                   'no vrrp 40 bfd ipv6', 'vrrp 40 ip version 2'])
    end

    let(:entity) do
      { 30 => { primary_ip: '40.10.5.31', delay_reload: 0,
                description: 'The description', enable: false, ip_version: 2,
                mac_addr_adv_interval: 30, preempt: false, preempt_delay_min: 0,
                preempt_delay_reload: 0, priority: 100, secondary_ip: [],
                timers_advertise: 1,
                track: [
                  { name: 'Ethernet1', action: 'decrement', amount: 5 }
                ]
        },
        40 => { primary_ip: '40.10.5.32', delay_reload: 0, description: nil,
                enable: true, ip_version: 2, mac_addr_adv_interval: 30,
                preempt: true, preempt_delay_min: 0, preempt_delay_reload: 0,
                priority: 200, secondary_ip: [], timers_advertise: 1,
                track: @tracks
        }
      }
    end

    it 'returns the virtual router resource' do
      expect(subject.get('Vlan150')).to eq(entity)
    end
  end

  describe '#getall' do
    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'returns the virtual router collection' do
      expect(subject.getall).to include('Vlan100')
      expect(subject.getall).to include('Vlan150')
    end
  end

  describe '#create' do
    before do
      node.config(['no interface Vlan100'])
    end

    it 'creates a new virtual router with enable true' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, enable: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'creates a new virtual router with enable false' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to include(9)
    end

    it 'creates a new virtual router with primary ip' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '1.2.3.4')).to be_truthy
      expect(subject.get('Vlan100')[9][:primary_ip]).to eq('1.2.3.4')
    end

    it 'creates a new virtual router with priority' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '1.2.3.4',
                                          priority: 100)).to be_truthy
      expect(subject.get('Vlan100')[9][:priority]).to eq(100)
    end

    it 'creates a new virtual router with description' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, description: 'Desc')).to be_truthy
      expect(subject.get('Vlan100')[9][:description]).to eq('Desc')
    end

    it 'creates a new virtual router with secondary ips' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100', 9,
                            secondary_ip: ['100.99.98.71',
                                           '100.99.98.70'])).to be_truthy
      expect(subject.get('Vlan100')[9][:secondary_ip]).to eq(['100.99.98.70',
                                                              '100.99.98.71'])
    end

    it 'creates a new virtual router with ip version 2' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100',
                            9,
                            primary_ip: '100.99.98.100',
                            ip_version: 2)).to be_truthy
      expect(subject.get('Vlan100')[9][:ip_version]).to eq(2)
    end

    it 'creates a new virtual router with timers advertise' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, timers_advertise: 77)).to be_truthy
      expect(subject.get('Vlan100')[9][:timers_advertise]).to eq(77)
    end

    it 'creates a new virtual router with mac addr adv interval' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, mac_addr_adv_interval: 77))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:mac_addr_adv_interval]).to eq(77)
    end

    it 'creates a new virtual router with preemt true' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100', 9, preempt: true)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(true)
    end

    it 'creates a new virtual router with preemt false' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, preempt: false)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(false)
    end

    it 'creates a new virtual router with preempt delay min' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, preempt_delay_min: 100))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:preempt_delay_min]).to eq(100)
    end

    it 'creates a new virtual router with preempt delay reload' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, preempt_delay_reload: 100))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:preempt_delay_reload]).to eq(100)
    end

    it 'creates a new virtual router with preempt delay reload' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, delay_reload: 100)).to be_truthy
      expect(subject.get('Vlan100')[9][:delay_reload]).to eq(100)
    end

    it 'creates a new virtual router with track values' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100',
                            9,
                            track: [{ name: 'Ethernet3',
                                      action: 'decrement',
                                      amount: 33 },
                                    { name: 'Ethernet2',
                                      action: 'decrement',
                                      amount: 22 },
                                    { name: 'Ethernet2',
                                      action: 'shutdown' }])).to be_truthy
      expect(subject.get('Vlan100')[9][:track]).to eq(@tracks)
    end

    it 'creates a new virtual router resource with enable and primary ip' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, enable: true, primary_ip: '1.2.3.4'))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:primary_ip]).to eq('1.2.3.4')
    end

    it 'creates a new virtual router resource with enable and priority' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100', 9, enable: true, priority: 100))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:priority]).to eq(100)
    end

    it 'creates a new virtual router resource with enable and description' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, enable: true, description: 'Desc'))
        .to be_truthy
      expect(subject.get('Vlan100')[9][:description]).to eq('Desc')
    end

    it 'creates a new virtual router resource with enable and secondary_ip' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100',
                            9,
                            enable: true,
                            secondary_ip: ['1.2.3.1',
                                           '1.2.3.2',
                                           '1.2.3.3', '1.2.3.4'])).to be_truthy
      expect(subject.get('Vlan100')[9][:secondary_ip]).to eq(@sec_ips)
    end

    it 'creates a new virtual router resource with all options set' do
      expect(subject.get('Vlan100')).to eq(nil)
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.create('Vlan100',
                            9,
                            enable: true,
                            priority: 100,
                            description: 'Desc',
                            secondary_ip: ['100.99.98.71',
                                           '100.99.98.70'],
                            ip_version: 2,
                            timers_advertise: 77,
                            mac_addr_adv_interval: 77,
                            preempt: true,
                            preempt_delay_min: 100,
                            preempt_delay_reload: 100,
                            delay_reload: 100,
                            track: [{ name: 'Ethernet3',
                                      action: 'decrement',
                                      amount: 33 },
                                    { name: 'Ethernet2',
                                      action: 'decrement',
                                      amount: 22 },
                                    { name: 'Ethernet2',
                                      action: 'shutdown' }])).to be_truthy
    end

    it 'raises ArgumentError for create without options' do
      expect { subject.create('Vlan100', 9) }.to \
        raise_error ArgumentError
    end
  end

  describe '#delete' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'deletes a virtual router resource' do
      expect(subject.delete('Vlan100', 9)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#default' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'sets virtual router resource to default' do
      expect(subject.default('Vlan100', 9)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_shutdown' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'enable Vlan100 vrid 9' do
      expect(subject.set_shutdown('Vlan100', 9)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'disable Vlan100 vrid 9' do
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.set_shutdown('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')[9][:enable]).to eq(false)
    end

    it 'defaults Vlan100 vrid 9' do
      expect(subject.set_shutdown('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_shutdown('Vlan100', 9, enable: false,
                                                default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_primary_ip' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set primary IP address' do
      expect(subject.set_primary_ip('Vlan100', 9,
                                    value: '1.2.3.4')).to be_truthy
      expect(subject.get('Vlan100')[9][:primary_ip]).to eq('1.2.3.4')
    end

    it 'disable primary IP address' do
      expect(subject.set_primary_ip('Vlan100', 9, value: '1.2.3.4',
                                                  enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults primary IP address' do
      expect(subject.set_primary_ip('Vlan100', 9, value: '1.2.3.4',
                                                  default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_primary_ip('Vlan100', 9, enable: false,
                                                  value: '1.2.3.4',
                                                  default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_priority' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set priority' do
      expect(subject.set_priority('Vlan100', 9, value: 13)).to be_truthy
      expect(subject.get('Vlan100')[9][:priority]).to eq(13)
    end

    it 'disable priority' do
      expect(subject.set_priority('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults priority' do
      expect(subject.set_priority('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_priority('Vlan100', 9, enable: false,
                                                default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_description' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set description' do
      expect(subject.set_description('Vlan100', 9,
                                     value: 'Howdy')).to be_truthy
      expect(subject.get('Vlan100')[9][:description]).to eq('Howdy')
    end

    it 'disable description' do
      expect(subject.set_description('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults description' do
      expect(subject.set_description('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_description('Vlan100', 9, enable: false,
                                                   default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_secondary_ip' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set secondary IP addresses' do
      # Set current IP addresses
      expect(subject.set_secondary_ip('Vlan100', 9, @sec_ips)).to be_truthy
      expect(subject.get('Vlan100')[9][:secondary_ip]).to eq(@sec_ips)
    end

    it 'remove all secondary IP addresses' do
      # Set current IP addresses
      expect(subject.set_secondary_ip('Vlan100', 9, @sec_ips)).to be_truthy
      # Delete all IP addresses
      expect(subject.set_secondary_ip('Vlan100', 9, [])).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_ip_version' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set VRRP version' do
      expect(subject.set_ip_version('Vlan100', 9, value: 3)).to be_truthy
      expect(subject.get('Vlan100')[9][:ip_version]).to eq(3)
    end

    it 'disable VRRP version' do
      expect(subject.set_ip_version('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults VRRP version' do
      expect(subject.set_ip_version('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_ip_version('Vlan100', 9, enable: false,
                                                  default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_timers_advertise' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set advertise timer' do
      expect(subject.set_timers_advertise('Vlan100', 9, value: 7)).to be_truthy
      expect(subject.get('Vlan100')[9][:timers_advertise]).to eq(7)
    end

    it 'disable advertise timer' do
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults advertise timer' do
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          enable: false,
                                          default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_mac_addr_adv_interval' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'set mac address advertisement interval' do
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               value: 12)).to be_truthy
      expect(subject.get('Vlan100')[9][:mac_addr_adv_interval]).to eq(12)
    end

    it 'disable mac address advertisement interval' do
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults mac address advertisement interval' do
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               enable: false,
                                               default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_preempt' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'enable preempt mode' do
      expect(subject.create('Vlan100', 9, primary_ip: '100.99.98.100'))
        .to be_truthy
      expect(subject.set_preempt('Vlan100', 9)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(true)
    end

    it 'disable preempt mode' do
      expect(subject.set_preempt('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(false)
    end

    it 'defaults preempt mode' do
      expect(subject.set_preempt('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(false)
    end

    it 'default option takes precedence' do
      expect(subject.set_preempt('Vlan100', 9, enable: false,
                                               default: true)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt]).to eq(false)
    end
  end

  describe '#set_preempt_delay_min' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'enable preempt mode' do
      expect(subject.set_preempt_delay_min('Vlan100', 9, value: 8)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt_delay_min]).to eq(8)
    end

    it 'disable preempt mode' do
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults preempt mode' do
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           enable: false,
                                           default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_preempt_delay_reload' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'enable preempt delay reload' do
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              value: 8)).to be_truthy
      expect(subject.get('Vlan100')[9][:preempt_delay_reload]).to eq(8)
    end

    it 'disable preempt delay reload' do
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults preempt delay reload' do
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              enable: false,
                                              default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_delay_reload' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    it 'enable delay reload' do
      expect(subject.set_delay_reload('Vlan100', 9, value: 8)).to be_truthy
      expect(subject.get('Vlan100')[9][:delay_reload]).to eq(8)
    end

    it 'disable delay reload' do
      expect(subject.set_delay_reload('Vlan100', 9, enable: false)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'defaults delay reload' do
      expect(subject.set_delay_reload('Vlan100', 9, default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'default option takes precedence' do
      expect(subject.set_delay_reload('Vlan100', 9,
                                      enable: false,
                                      default: true)).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end
  end

  describe '#set_tracks' do
    before do
      node.config(['no interface Vlan100', 'interface Vlan100',
                   'vrrp 9 priority 100'])
    end

    before :all do
      @bad_key = [{ nombre: 'Ethernet3', action: 'decrement', amount: 33 }]
      @miss_key = [{ action: 'decrement', amount: 33 }]
      @bad_action = [{ name: 'Ethernet3', action: 'dec', amount: 33 }]
      @sem_key = [{ name: 'Ethernet3', action: 'shutdown', amount: 33 }]
      @bad_amount = [{ name: 'Ethernet3', action: 'decrement', amount: -1 }]
    end

    it 'set tracks' do
      # Set current IP addresses
      expect(subject.set_tracks('Vlan100', 9, @tracks)).to be_truthy
      expect(subject.get('Vlan100')[9][:track]).to eq(@tracks)
    end

    it 'remove all tracks' do
      # Set current IP addresses
      expect(subject.set_tracks('Vlan100', 9, @tracks)).to be_truthy
      # Delete all IP addresses
      expect(subject.set_tracks('Vlan100', 9, [])).to be_truthy
      expect(subject.get('Vlan100')).to eq({})
    end

    it 'raises ArgumentError for track hash with a bad key' do
      expect { subject.set_tracks('Vlan100', 9, @bad_key) }.to \
        raise_error ArgumentError
    end

    it 'raises ArgumentError for track hash with missing required key' do
      expect { subject.set_tracks('Vlan100', 9, @miss_key) }.to \
        raise_error ArgumentError
    end

    it 'raises ArgumentError for track hash with invalid action' do
      expect { subject.set_tracks('Vlan100', 9, @bad_action) }.to \
        raise_error ArgumentError
    end

    it 'raises ArgumentError for track hash with shutdown and amount' do
      expect { subject.set_tracks('Vlan100', 9, @sem_key) }.to \
        raise_error ArgumentError
    end

    it 'raises ArgumentError for track hash with negative amount' do
      expect { subject.set_tracks('Vlan100', 9, @bad_amount) }.to \
        raise_error ArgumentError
    end
  end
end
