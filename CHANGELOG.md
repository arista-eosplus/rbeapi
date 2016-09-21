Ruby Client for eAPI
====================

## [v1.0](https://github.com/arista-eosplus/rbeapi/releases/tag/v1.0), September, 2016

[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.5.1...v1.0)

Changes to API:
- Fix issues setting interface speeds. Speed is now returned as a string
  instead of a list. ([rknaus](https://github.com/rknaus))

Enhancements and Fixes:
- Added set_trunk_group method to vlans API
- Fix #118 SWIX package uninstall issue
- Fix #123 which could return incorrect value for iprouting when VRFs are
  enabled
- Limit several rubygem deps when testing with Ruby 1.9
- Add load-interval option in ipinterfaces
  ([n1cn0c](https://github.com/n1cn0c))
- Fix #142 parsing of VxLAN interface multicast group parsing
  ([mrvinti](https://github.com/mrvinti))
- Improve spanning-tree MST handling ([rknaus](https://github.com/rknaus))
- Add rbeapi/switchconfig to do block-by-block comparisons of EOS configs. This
  enables configuration management tools like Chef and Puppet to take a current
  and proposed running-config as a text blob and easily determine if they
  differ.
- Add swix packaging of rbeapi rubygems for use with Chef-client on EOS
- Ensure that get_config, node.running_config, and node_startup_config return
  sane value even when a config does not exist.

## v0.5.1, February, 2016

- Fix issue where vlans API was not returning all configured vlan trunk_groups.

## v0.5.0, January, 2016

- Add optional ‘mode’ parameter to set_members() method in port-channel
  interfaces API
- Add support for trunk groups
- Ensure multiple connections based on the wildcard settings do not clobber
  each other.
- Add ‘terminal’ to the ‘configure’ command to workaround AAA issue
- Fix issue where ‘enablepw’ in the eapi.conf was not properly used
- Catch errors and syslog them when parsing eapi conf file.
  In the event of an unparsable eapi.conf, a syslog warning will be generated
  but the app will continue to attempt to utilize the default localhost conn.
- Ensure that nil is returned when getting nonexistent username
- Ensure all parse methods are private
- Add tests for timeout values
- Update framework tests
- Add unit tests for switchports
- Address code coverage gaps


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
