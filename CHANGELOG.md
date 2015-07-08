Ruby Client for eAPI
====================

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
