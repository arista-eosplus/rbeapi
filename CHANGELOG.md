Ruby Client for eAPI
====================

## v0.4.0, November, 2015

- New users API
- New routemap API
- New vrrp API
- BGP API: Add support for maximum_paths and maximum_ecmp_paths
- System API: add support for managing the global EOS ‘ip routing’ setting
- Updated RPM/SWIX packaging to handle Puppet All-In-One (AIO) agent paths
  New package names are: rbeapi, rbeapi-puppet3 (formerly pe-puppet),
  and rbeapi-puppet-aio
- Fixed port-channel get_members() issue with EOS 4.15 and above.
- Fixed issue with the eapi.conf wildcard connection
- Fixed issue that would cause a traceback when searching for eapi.conf if
  $HOME was not set


## v0.3.0, August, 2015

- API Change: Eliminated overloading the value option in command_builder. When
  the value is set it is used as a value in building the command. When the value
  is false then the command is negated. This doesn’t allow a value to be
  specified when the command is negated.
- APIs updated to take advantage of command_builder()
- Add staticroutes API
- Fix issue which would cause the module to fail to load when $HOME was not set
- Fix builds (all_rpms) to work on Ubuntu
- Fix rbeapi rubygem RPM requires

## v0.2.0, July, 2015

- Change the default transport to https
- Add new dependency: rubygem-netaddr
- Add [api.acl] with support for standard ACLs
- Add capability to build all necessary RPMS for EOS from the Rakefile
- Add `[connection:*]` syntax to eapi.conf to provide defaults for unspecified hosts
- Add configurable read and open timeouts
- Add new methods to the Entity class
- Add new VNI mapping to VxLan interface
- Add port-fast support to [api.stp]
- Fix issue with sending calls to interface instance by name
- Fix [api.vlans] issue parsing vlan name with a `-` character
- Fix issue where [api.interfaces] could return duplicate port-channel members on MLAG interfaces
- Fix missing OpenSSL require
- Fix Rubocop warnings


## v0.1.0, 2/25/2015

- Initial public release of rbeapi
