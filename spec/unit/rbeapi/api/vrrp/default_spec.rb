require 'spec_helper'

require 'rbeapi/api/vrrp'

include FixtureHelpers

describe Rbeapi::Api::Vrrp do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  def vrrp
    vrrp = Fixtures[:vrrp]
    return vrrp if vrrp
    fixture('vrrp', format: :text, dir: File.dirname(__FILE__))
  end

  before :all do
    @sec_ips = ['1.2.3.1', '1.2.3.2', '1.2.3.3', '1.2.3.4']
    @tracks = [{ name: 'Ethernet3', action: 'decrement', amount: 33 },
               { name: 'Ethernet2', action: 'decrement', amount: 22 },
               { name: 'Ethernet2', action: 'shutdown' }]

    # Create the secondary IP commands array
    @sec_ips_cmds = []
    @sec_ips.each do |addr|
      @sec_ips_cmds << "vrrp 9 ip #{addr} secondary"
    end

    # Create the track commands array
    @track_cmds = []
    @tracks.each do |tk|
      cmd = "vrrp 9 track #{tk[:name]} #{tk[:action]}"
      cmd << " #{tk[:amount]}" if tk.key?(:amount)
      @track_cmds << cmd
    end
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(vrrp)
  end

  describe '#get' do
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
    it 'returns the virtual router collection' do
      expect(subject.getall).to include('Vlan100')
      expect(subject.getall).to include('Vlan150')
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has only one entry' do
      expect(subject.getall.size).to eq(2)
    end
  end

  describe '#create' do
    before :all do
      @values = [
        { option: :enable, value: true, cmd: ['no vrrp 9 shutdown'] },
        { option: :enable, value: false, cmd: ['vrrp 9 shutdown'] },
        { option: :primary_ip, value: '1.2.3.4', cmd: ['vrrp 9 ip 1.2.3.4'] },
        { option: :priority, value: 100, cmd: ['vrrp 9 priority 100'] },
        { option: :description, value: 'Desc',
          cmd: ['vrrp 9 description Desc'] },
        { option: :secondary_ip, value: @sec_ips, cmd: @sec_ips_cmds },
        { option: :ip_version, value: 2, cmd: ['vrrp 9 ip version 2'] },
        { option: :timers_advertise, value: 77,
          cmd: ['vrrp 9 timers advertise 77'] },
        { option: :mac_addr_adv_interval, value: 77,
          cmd: ['vrrp 9 mac-address advertisement-interval 77'] },
        { option: :preempt, value: true, cmd: ['vrrp 9 preempt'] },
        { option: :preempt, value: false, cmd: ['no vrrp 9 preempt'] },
        { option: :preempt_delay_min, value: 100,
          cmd: ['vrrp 9 preempt delay minimum 100'] },
        { option: :preempt_delay_reload, value: 100,
          cmd: ['vrrp 9 preempt delay reload 100'] },
        { option: :delay_reload, value: 100, cmd: ['vrrp 9 delay reload 100'] },
        { option: :track, value: @tracks, cmd: @track_cmds }
      ]

      # Build the testcases specifying one option per test
      @test_opts1 = []
      @values.each do |entry|
        opts = Hash[entry[:option], entry[:value]]
        @test_opts1.push(opts: opts, cmds: entry[:cmd])
      end

      # Build the testcases specifying two options per test
      @test_opts2 = []
      @values.each_with_index do |entry1, idx1|
        @values.each_with_index do |entry2, idx2|
          # Skip if both options are the same
          next if entry1[:option] == entry2[:option]
          # Skip if already generated a testcase for this pair
          next if idx2 <= idx1
          opts = Hash[entry1[:option], entry1[:value],
                      entry2[:option], entry2[:value]]
          @test_opts2.push(opts: opts, cmds: entry1[:cmd] + entry2[:cmd])
        end
      end
    end

    it 'creates a new virtual router resource with one option set' do
      @test_opts1.each do |test|
        cmds = ['interface Vlan100']
        cmds += test[:cmds]

        expect(node).to receive(:config).with(cmds)
        expect(subject.create('Vlan100', 9, test[:opts])).to be_truthy
      end
    end

    it 'creates a new virtual router resource with two options set' do
      @test_opts2.each do |test|
        cmds = ['interface Vlan100']
        cmds += test[:cmds]

        expect(node).to receive(:config).with(cmds)
        expect(subject.create('Vlan100', 9, test[:opts])).to be_truthy
      end
    end

    it 'creates a new virtual router resource with all options set' do
      @test_opts3 = []
      opts = {}
      cmds = ['interface Vlan100']
      @values.each do |entry|
        # Skip boolean pairs in the options that are false because
        # the option can only be set once.
        next unless entry[:value]
        opts[entry[:option]] = entry[:value]
        entry[:cmd].each do |cmd|
          cmds << cmd
        end
      end

      expect(node).to receive(:config).with(cmds)
      expect(subject.create('Vlan100', 9, opts)).to be_truthy
    end

    it 'raises ArgumentError for create without options' do
      expect { subject.create('Vlan100', 9) }.to \
        raise_error ArgumentError
    end
  end

  describe '#delete' do
    it 'deletes a virtual router resource' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9'])
      expect(subject.delete('Vlan100', 9)).to be_truthy
    end
  end

  describe '#default' do
    it 'sets virtual router resource to default' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9'])
      expect(subject.default('Vlan100', 9)).to be_truthy
    end
  end

  describe '#set_shutdown' do
    it 'enable Vlan100 vrid 9' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 shutdown'])
      expect(subject.set_shutdown('Vlan100', 9)).to be_truthy
    end

    it 'disable Vlan100 vrid 9' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 shutdown'])
      expect(subject.set_shutdown('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults Vlan100 vrid 9' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 shutdown'])
      expect(subject.set_shutdown('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 shutdown'])
      expect(subject.set_shutdown('Vlan100', 9, enable: false,
                                                default: true)).to be_truthy
    end
  end

  describe '#set_primary_ip' do
    it 'set primary IP address' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 ip 1.2.3.4'])
      expect(subject.set_primary_ip('Vlan100', 9,
                                    value: '1.2.3.4')).to be_truthy
    end

    it 'disable primary IP address' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 ip 1.2.3.4'])
      expect(subject.set_primary_ip('Vlan100', 9, value: '1.2.3.4',
                                                  enable: false)).to be_truthy
    end

    it 'defaults primary IP address' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 ip 1.2.3.4'])
      expect(subject.set_primary_ip('Vlan100', 9, value: '1.2.3.4',
                                                  default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 ip 1.2.3.4'])
      expect(subject.set_primary_ip('Vlan100', 9, enable: false,
                                                  value: '1.2.3.4',
                                                  default: true)).to be_truthy
    end
  end

  describe '#set_priority' do
    it 'set priority' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 priority 13'])
      expect(subject.set_priority('Vlan100', 9, value: 13)).to be_truthy
    end

    it 'disable priority' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 priority'])
      expect(subject.set_priority('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults priority' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 priority'])
      expect(subject.set_priority('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 priority'])
      expect(subject.set_priority('Vlan100', 9, enable: false,
                                                default: true)).to be_truthy
    end
  end

  describe '#set_description' do
    it 'set description' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 description Howdy'])
      expect(subject.set_description('Vlan100', 9,
                                     value: 'Howdy')).to be_truthy
    end

    it 'disable description' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 description'])
      expect(subject.set_description('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults description' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 description'])
      expect(subject.set_description('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 description'])
      expect(subject.set_description('Vlan100', 9, enable: false,
                                                   default: true)).to be_truthy
    end
  end

  describe '#set_secondary_ip' do
    before :all do
      @cmds = ['interface Vlan100']
      @cmds += @sec_ips_cmds
    end
    it 'set secondary IP addresses' do
      # Set current IP addresses
      expect(node).to receive(:config).with(@cmds)
      expect(subject.set_secondary_ip('Vlan100', 9, @sec_ips)).to be_truthy
    end

    it 'remove all secondary IP addresses' do
      # Set current IP addresses
      expect(node).to receive(:config).with(@cmds)
      expect(subject.set_secondary_ip('Vlan100', 9, @sec_ips)).to be_truthy
      # Delete all IP addresses
      expect(subject.set_secondary_ip('Vlan100', 9, [])).to be_truthy
    end
  end

  describe '#set_ip_version' do
    it 'set VRRP version' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 ip version 3'])
      expect(subject.set_ip_version('Vlan100', 9, value: 3)).to be_truthy
    end

    it 'disable VRRP version' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 ip version'])
      expect(subject.set_ip_version('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults VRRP version' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 ip version'])
      expect(subject.set_ip_version('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 ip version'])
      expect(subject.set_ip_version('Vlan100', 9, enable: false,
                                                  default: true)).to be_truthy
    end
  end

  describe '#set_timers_advertise' do
    it 'set advertise timer' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 timers advertise 7'])
      expect(subject.set_timers_advertise('Vlan100', 9, value: 7)).to be_truthy
    end

    it 'disable advertise timer' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 timers advertise'])
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          enable: false)).to be_truthy
    end

    it 'defaults advertise timer' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 timers advertise'])
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 timers advertise'])
      expect(subject.set_timers_advertise('Vlan100', 9,
                                          enable: false,
                                          default: true)).to be_truthy
    end
  end

  describe '#set_mac_addr_adv_interval' do
    it 'set mac address advertisement interval' do
      expect(node).to receive(:config)
        .with(['interface Vlan100',
               'vrrp 9 mac-address advertisement-interval 12'])
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               value: 12)).to be_truthy
    end

    it 'disable mac address advertisement interval' do
      expect(node).to receive(:config)
        .with(['interface Vlan100',
               'no vrrp 9 mac-address advertisement-interval'])
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               enable: false)).to be_truthy
    end

    it 'defaults mac address advertisement interval' do
      expect(node).to receive(:config)
        .with(['interface Vlan100',
               'default vrrp 9 mac-address advertisement-interval'])
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config)
        .with(['interface Vlan100',
               'default vrrp 9 mac-address advertisement-interval'])
      expect(subject.set_mac_addr_adv_interval('Vlan100', 9,
                                               enable: false,
                                               default: true)).to be_truthy
    end
  end

  describe '#set_preempt' do
    it 'enable preempt mode' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 preempt'])
      expect(subject.set_preempt('Vlan100', 9)).to be_truthy
    end

    it 'disable preempt mode' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 preempt'])
      expect(subject.set_preempt('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults preempt mode' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 preempt'])
      expect(subject.set_preempt('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'default vrrp 9 preempt'])
      expect(subject.set_preempt('Vlan100', 9, enable: false,
                                               default: true)).to be_truthy
    end
  end

  describe '#set_preempt_delay_min' do
    it 'enable preempt mode' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 preempt delay minimum 8'])
      expect(subject.set_preempt_delay_min('Vlan100', 9, value: 8)).to be_truthy
    end

    it 'disable preempt mode' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 preempt delay minimum'])
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           enable: false)).to be_truthy
    end

    it 'defaults preempt mode' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 preempt delay minimum'])
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 preempt delay minimum'])
      expect(subject.set_preempt_delay_min('Vlan100', 9,
                                           enable: false,
                                           default: true)).to be_truthy
    end
  end

  describe '#set_preempt_delay_reload' do
    it 'enable preempt delay reload' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 preempt delay reload 8'])
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              value: 8)).to be_truthy
    end

    it 'disable preempt delay reload' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 preempt delay reload'])
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              enable: false)).to be_truthy
    end

    it 'defaults preempt delay reload' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 preempt delay reload'])
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 preempt delay reload'])
      expect(subject.set_preempt_delay_reload('Vlan100', 9,
                                              enable: false,
                                              default: true)).to be_truthy
    end
  end

  describe '#set_delay_reload' do
    it 'enable delay reload' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'vrrp 9 delay reload 8'])
      expect(subject.set_delay_reload('Vlan100', 9, value: 8)).to be_truthy
    end

    it 'disable delay reload' do
      expect(node).to receive(:config).with(['interface Vlan100',
                                             'no vrrp 9 delay reload'])
      expect(subject.set_delay_reload('Vlan100', 9, enable: false)).to be_truthy
    end

    it 'defaults delay reload' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 delay reload'])
      expect(subject.set_delay_reload('Vlan100', 9, default: true)).to be_truthy
    end

    it 'default option takes precedence' do
      expect(node).to receive(:config)
        .with(['interface Vlan100', 'default vrrp 9 delay reload'])
      expect(subject.set_delay_reload('Vlan100', 9,
                                      enable: false,
                                      default: true)).to be_truthy
    end
  end

  describe '#set_tracks' do
    before :all do
      @cmds = ['interface Vlan100']
      @cmds += @track_cmds

      @bad_key = [{ nombre: 'Ethernet3', action: 'decrement', amount: 33 }]
      @miss_key = [{ action: 'decrement', amount: 33 }]
      @bad_action = [{ name: 'Ethernet3', action: 'dec', amount: 33 }]
      @sem_key = [{ name: 'Ethernet3', action: 'shutdown', amount: 33 }]
      @bad_amount = [{ name: 'Ethernet3', action: 'decrement', amount: -1 }]
    end

    it 'set tracks' do
      # Set current IP addresses
      expect(node).to receive(:config).with(@cmds)
      expect(subject.set_tracks('Vlan100', 9, @tracks)).to be_truthy
    end

    it 'remove all tracks' do
      # Set current IP addresses
      expect(node).to receive(:config).with(@cmds)
      expect(subject.set_tracks('Vlan100', 9, @tracks)).to be_truthy
      # Delete all IP addresses
      expect(subject.set_tracks('Vlan100', 9, [])).to be_truthy
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
