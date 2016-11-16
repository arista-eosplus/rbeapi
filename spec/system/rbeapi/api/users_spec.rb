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
require 'rbeapi/api/users'

describe Rbeapi::Api::Users do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  let(:sshkey) do
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKL1UtBALa4CvFUsHUipN' \
    'ymA04qCXuAtTwNcMj84bTUzUI+q7mdzRCTLkllXeVxKuBnaTm2PW7W67K5C' \
    'Vpl0EVCm6IY7FS7kc4nlnD/tFvTvShy/fzYQRAdM7ZfVtegW8sMSFJzBR/T' \
    '/Y/sxI16Y/dQb8fC3la9T25XOrzsFrQiKRZmJGwg8d+0RLxpfMg0s/9ATwQ' \
    'Kp6tPoLE4f3dKlAgSk5eENyVLA3RsypWADHpenHPcB7sa8D38e1TS+n+EUy' \
    'Adb3Yov+5ESAbgLIJLd52Xv+FyYi0c2L49ByBjcRrupp4zfXn4DNRnEG4K6' \
    'GcmswHuMEGZv5vjJ9OYaaaaaaa'
  end

  let(:secret) do
    '$6$RMxgK5ALGIf.nWEC$tHuKCyfNtJMCY561P52dTzHUmYMmLxb/M' \
    'xik.j3vMUs8lMCPocM00/NAS.SN6GCWx7d/vQIgxnClyQLAb7n3x0'
  end

  let(:md5_secret) do
    '$1$Ehb5lL0D$N3MgrkfMFxmeh0FSZ5sEZ1'
  end

  let(:test) do
    { name: 'rbeapi',
      privilege: 1,
      role: nil,
      nopassword: false,
      encryption: 'md5',
      secret: md5_secret,
      sshkey: sshkey }
  end

  describe '#getall' do
    let(:resource) { subject.getall }

    let(:test1_entries) do
      { 'admin' => { name: 'admin', privilege: 1,
                     role: 'network-admin', nopassword: true,
                     encryption: nil, secret: nil, sshkey: nil },
        'rbeapi' => { name: 'rbeapi', privilege: 1, role: nil,
                      nopassword: false, encryption: 'md5',
                      secret: md5_secret,
                      sshkey: sshkey } }
    end

    before do
      node.config(['no username rbeapi',
                   'no username user1',
                   'username admin privilege 1 role network-admin nopassword',
                   "username rbeapi privilege 1 secret 5 #{md5_secret}",
                   "username rbeapi sshkey #{sshkey}",
                   'management defaults', 'default secret hash'])
    end

    it 'returns the username collection' do
      expect(subject.getall).to include(test1_entries)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end
  end

  describe '#get' do
    it 'returns the user resource for given name' do
      expect(subject.get('rbeapi')).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get('rbeapi')).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get('rbeapi').size).to eq(7)
    end
  end

  describe '#create' do
    before do
      node.config(['no username rbeapi'])
    end

    it 'create a new user name with no password' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi', nopassword: :true)).to be_truthy
      expect(subject.get('rbeapi')[:nopassword]).to eq(true)
    end

    it 'create a new user name with no password and privilege' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            privilege: 4,
                            nopassword: :true)).to be_truthy
      expect(subject.get('rbeapi')[:privilege]).to eq(4)
    end

    it 'create a new user name with no password, privilege, and role' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            privilege: 4,
                            role: 'net-minion',
                            nopassword: :true)).to be_truthy
      expect(subject.get('rbeapi')[:privilege]).to eq(4)
      expect(subject.get('rbeapi')[:role]).to eq('net-minion')
      expect(subject.get('rbeapi')[:nopassword]).to eq(true)
    end

    it 'create a new user name with a password' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi', secret: 'icanttellyou')).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('md5')
    end

    it 'create a new user name with a password and privilege' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            privilege: 5)).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('md5')
      expect(subject.get('rbeapi')[:privilege]).to eq(5)
    end

    it 'create a new user name with a password, privilege, and role' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            privilege: 5, role: 'net')).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('md5')
      expect(subject.get('rbeapi')[:privilege]).to eq(5)
      expect(subject.get('rbeapi')[:role]).to eq('net')
    end

    it 'create a new user name with a password and md5 encryption' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            secret: '$1$Wb4zN5EH$ILNgYb3Ehzs85S9KpoFW4.',
                            encryption: 'md5')).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('md5')
      expect(subject.get('rbeapi')[:secret])
        .to eq('$1$Wb4zN5EH$ILNgYb3Ehzs85S9KpoFW4.')
    end

    it 'create a new user name with a password and sha512 encryption' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            secret: secret,
                            encryption: 'sha512')).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('sha512')
    end

    it 'create a new user name with a password, sha512 encryption, and key' do
      expect(subject.get('rbeapi')).to eq(nil)
      expect(subject.create('rbeapi',
                            secret: secret,
                            encryption: 'sha512',
                            sshkey: sshkey)).to be_truthy
      expect(subject.get('rbeapi')[:encryption]).to eq('sha512')
    end

    it 'raises ArgumentError for create without required args ' do
      expect { subject.create('rbeapi') }.to \
        raise_error ArgumentError
    end

    it 'raises ArgumentError for invalid encryption value' do
      expect { subject.create('name', encryption: 'bogus') }.to \
        raise_error ArgumentError
    end
  end

  describe '#delete' do
    before do
      node.config(['username user1 privilege 1 role network-admin nopassword'])
    end

    it 'delete a username resource' do
      expect(subject.get('user1')[:name]).to eq('user1')
      expect(subject.delete('user1')).to be_truthy
      expect(subject.get('user1')).to eq(nil)
    end
  end

  describe '#default' do
    before do
      node.config(['username user1 privilege 1 role network-admin nopassword'])
    end

    it 'sets username resource to default value' do
      expect(subject.get('user1')[:name]).to eq('user1')
      expect(subject.default('user1')).to be_truthy
      expect(subject.get('user1')).to eq(nil)
    end
  end

  describe '#set_privilege' do
    before do
      node.config(['no username rbeapi',
                   'username rbeapi role network-admin nopassword'])
    end

    it 'set the privilege' do
      expect(subject.set_privilege('rbeapi', value: '13')).to be_truthy
      expect(subject.get('rbeapi')[:privilege]).to eq(13)
    end

    it 'remove the privilege without a value' do
      expect(subject.set_privilege('rbeapi', enable: false)).to be_truthy
      expect(subject.get('rbeapi')).to eq(nil)
    end

    it 'remove the privilege with a value' do
      expect(subject.set_privilege('rbeapi', value: '13', enable: false))
        .to be_truthy
      expect(subject.get('rbeapi')).to eq(nil)
    end

    it 'defaults the privilege without a value' do
      expect(subject.set_privilege('rbeapi', default: true)).to be_truthy
      expect(subject.get('rbeapi')).to eq(nil)
    end

    it 'defaults the privilege with a value' do
      expect(subject.set_privilege('rbeapi', value: '3', default: true))
        .to be_truthy
      expect(subject.get('rbeapi')).to eq(nil)
    end
  end

  describe '#set_role' do
    before do
      node.config(['no username rbeapi', 'username rbeapi nopassword'])
    end

    it 'set the role' do
      expect(subject.set_role('rbeapi', value: 'net-minion')).to be_truthy
      expect(subject.get('rbeapi')[:role]).to eq('net-minion')
    end

    it 'remove the role without a value' do
      expect(subject.set_role('rbeapi', enable: false)).to be_truthy
      expect(subject.get('rbeapi')[:role]).to eq(nil)
    end

    it 'remove the role with a value' do
      expect(subject.set_role('rbeapi', value: 'net', enable: false))
        .to be_truthy
      expect(subject.get('rbeapi')[:role]).to eq(nil)
    end

    it 'defaults the role without a value' do
      expect(subject.set_role('rbeapi', default: true)).to be_truthy
      expect(subject.get('rbeapi')[:role]).to eq(nil)
    end

    it 'defaults the role with a value' do
      expect(subject.set_role('rbeapi', value: 'net', default: true))
        .to be_truthy
      expect(subject.get('rbeapi')[:role]).to eq(nil)
    end
  end

  describe '#set_sshkey' do
    before do
      node.config(['no username rbeapi', 'username rbeapi nopassword'])
    end

    it 'set the sshkey' do
      expect(subject.set_sshkey('rbeapi', value: sshkey)).to be_truthy
    end

    it 'remove the sshkey with a value' do
      expect(subject.set_sshkey('rbeapi', value: sshkey, enable: false))
        .to be_truthy
      expect(subject.get('rbeapi')[:sshkey]).to eq(nil)
    end

    it 'defaults the sshkey without a value' do
      expect(subject.set_sshkey('rbeapi', default: true)).to be_truthy
      expect(subject.get('rbeapi')[:sshkey]).to eq(nil)
    end
  end
end
