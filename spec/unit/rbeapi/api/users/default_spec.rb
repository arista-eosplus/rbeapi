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

require 'rbeapi/api/users'

include FixtureHelpers

describe Rbeapi::Api::Users do
  subject { described_class.new(node) }

  let(:node) { double('node') }

  let(:sshkey) do
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKL1UtBALa4CvFUsHUipN' \
    'ymA04qCXuAtTwNcMj84bTUzUI+q7mdzRCTLkllXeVxKuBnaTm2PW7W67K5C' \
    'Vpl0EVCm6IY7FS7kc4nlnD/tFvTvShy/fzYQRAdM7ZfVtegW8sMSFJzBR/T' \
    '/Y/sxI16Y/dQb8fC3la9T25XOrzsFrQiKRZmJGwg8d+0RLxpfMg0s/9ATwQ' \
    'Kp6tPoLE4f3dKlAgSk5eENyVLA3RsypWADHpenHPcB7sa8D38e1TS+n+EUy' \
    'Adb3Yov+5ESAbgLIJLd52Xv+FyYi0c2L49ByBjcRrupp4zfXn4DNRnEG4K6' \
    'GcmswHuMEGZv5vjJ9OYaaaaaaa'
  end

  let(:test) do
    { name: 'rbeapi',
      privilege: 1,
      role: nil,
      nopassword: false,
      encryption: 'md5',
      secret: '$1$Ehb5lL0D$N3MgrkfMFxmeh0FSZ5sEZ1',
      sshkey: sshkey
    }
  end
  let(:name) { test[:name] }

  def users
    users = Fixtures[:users]
    return users if users
    fixture('users', format: :text, dir: File.dirname(__FILE__))
  end

  before :each do
    allow(subject.node).to receive(:running_config).and_return(users)
  end

  describe '#getall' do
    let(:test1_entries) do
      { 'admin' => { name: 'admin', privilege: 1,
                     role: 'network-admin', nopassword: true,
                     encryption: nil, secret: nil, sshkey: nil },
        'rbeapi' => { name: 'rbeapi', privilege: 1, role: nil,
                      nopassword: false, encryption: 'md5',
                      secret: '$1$Ehb5lL0D$N3MgrkfMFxmeh0FSZ5sEZ1',
                      sshkey: sshkey },
        'rbeapi1' => { name: 'rbeapi1', privilege: 2,
                       role: 'network-minon', nopassword: false,
                       encryption: 'cleartext', secret: 'icanttellyou',
                       sshkey: nil }
      }
    end

    it 'returns the username collection' do
      expect(subject.getall).to include(test1_entries)
    end

    it 'returns a hash collection' do
      expect(subject.getall).to be_a_kind_of(Hash)
    end

    it 'has three entries' do
      expect(subject.getall.size).to eq(3)
    end
  end

  describe '#get' do
    it 'returns the user resource for given name' do
      expect(subject.get(name)).to eq(test)
    end

    it 'returns a hash' do
      expect(subject.get(name)).to be_a_kind_of(Hash)
    end

    it 'has two entries' do
      expect(subject.get(name).size).to eq(7)
    end
  end

  describe '#create' do
    it 'create a new user name with no password' do
      expect(node).to receive(:config).with(['username rbeapi nopassword'])
      expect(subject.create('rbeapi', nopassword: :true)).to be_truthy
    end
    it 'create a new user name with no password and privilege' do
      expect(node).to receive(:config)
        .with(['username rbeapi privilege 4 nopassword'])
      expect(subject.create('rbeapi',
                            privilege: 4,
                            nopassword: :true)).to be_truthy
    end
    it 'create a new user name with no password, privilege, and role' do
      expect(node).to receive(:config)
        .with(['username rbeapi privilege 4 role net-minion nopassword'])
      expect(subject.create('rbeapi',
                            privilege: 4,
                            role: 'net-minion',
                            nopassword: :true)).to be_truthy
    end
    it 'create a new user name with a password' do
      expect(node).to receive(:config)
        .with(['username rbeapi secret 0 icanttellyou'])
      expect(subject.create('rbeapi', secret: 'icanttellyou')).to be_truthy
    end
    it 'create a new user name with a password and privilege' do
      expect(node).to receive(:config)
        .with(['username rbeapi privilege 5 secret 0 icanttellyou'])
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            privilege: 5)).to be_truthy
    end
    it 'create a new user name with a password, privilege, and role' do
      expect(node).to receive(:config)
        .with(['username rbeapi privilege 5 role net secret 0 icanttellyou'])
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            privilege: 5, role: 'net')).to be_truthy
    end
    it 'create a new user name with a password and md5 encryption' do
      expect(node).to receive(:config)
        .with(['username rbeapi secret 5 icanttellyou'])
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            encryption: 'md5')).to be_truthy
    end
    it 'create a new user name with a password and sha512 encryption' do
      expect(node).to receive(:config)
        .with(['username rbeapi secret sha512 icanttellyou'])
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            encryption: 'sha512')).to be_truthy
    end
    it 'create a new user name with a password, sha512 encryption, and key' do
      expect(node).to receive(:config)
        .with(['username rbeapi secret sha512 icanttellyou',
               "username rbeapi sshkey #{sshkey}"])
      expect(subject.create('rbeapi',
                            secret: 'icanttellyou',
                            encryption: 'sha512',
                            sshkey: sshkey)).to be_truthy
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
    it 'delete a username resource' do
      expect(node).to receive(:config).with('no username user1')
      expect(subject.delete('user1')).to be_truthy
    end
  end

  describe '#default' do
    it 'sets username resource to default value' do
      expect(node).to receive(:config)
        .with('default username user1')
      expect(subject.default('user1')).to be_truthy
    end
  end

  describe '#set_privilege' do
    it 'set the privilege' do
      expect(node).to receive(:config).with('username rbeapi privilege 13')
      expect(subject.set_privilege('rbeapi', value: '13')).to be_truthy
    end

    it 'remove the privilege without a value' do
      expect(node).to receive(:config).with('no username rbeapi privilege')
      expect(subject.set_privilege('rbeapi', enable: false)).to be_truthy
    end

    it 'remove the privilege with a value' do
      expect(node).to receive(:config).with('no username rbeapi privilege 13')
      expect(subject.set_privilege('rbeapi', value: '13', enable: false))
        .to be_truthy
    end

    it 'defaults the privilege without a value' do
      expect(node).to receive(:config).with('default username rbeapi privilege')
      expect(subject.set_privilege('rbeapi', default: true)).to be_truthy
    end

    it 'defaults the privilege with a value' do
      expect(node).to receive(:config).with('default username rb privilege 3')
      expect(subject.set_privilege('rb', value: '3', default: true))
        .to be_truthy
    end
  end

  describe '#set_role' do
    it 'set the role' do
      expect(node).to receive(:config).with('username rbeapi role net-minion')
      expect(subject.set_role('rbeapi', value: 'net-minion')).to be_truthy
    end

    it 'remove the role without a value' do
      expect(node).to receive(:config).with('no username rbeapi role')
      expect(subject.set_role('rbeapi', enable: false)).to be_truthy
    end

    it 'remove the role with a value' do
      expect(node).to receive(:config).with('no username rbeapi role net')
      expect(subject.set_role('rbeapi', value: 'net', enable: false))
        .to be_truthy
    end

    it 'defaults the role without a value' do
      expect(node).to receive(:config).with('default username rbeapi role')
      expect(subject.set_role('rbeapi', default: true)).to be_truthy
    end

    it 'defaults the role with a value' do
      expect(node).to receive(:config).with('default username rbeapi role net')
      expect(subject.set_role('rbeapi', value: 'net', default: true))
        .to be_truthy
    end
  end

  describe '#set_sshkey' do
    it 'set the sshkey' do
      expect(node).to receive(:config).with("username rbeapi sshkey #{sshkey}")
      expect(subject.set_sshkey('rbeapi', value: sshkey)).to be_truthy
    end

    it 'remove the sshkey with a value' do
      expect(node).to receive(:config).with("no username rb sshkey #{sshkey}")
      expect(subject.set_sshkey('rb', value: sshkey, enable: false))
        .to be_truthy
    end

    it 'defaults the sshkey without a value' do
      expect(node).to receive(:config).with('default username rbeapi sshkey')
      expect(subject.set_sshkey('rbeapi', default: true)).to be_truthy
    end
  end
end
