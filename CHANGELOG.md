# Change Log

## [1.0](https://github.com/arista-eosplus/rbeapi/tree/1.0) (2016-09-22)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.5.1...1.0)

**Implemented enhancements:**

- Need to validate value keyword in set methods when array [\#40](https://github.com/arista-eosplus/rbeapi/issues/40)
- Limit rubocop version when running ruby 1.9 [\#125](https://github.com/arista-eosplus/rbeapi/pull/125) ([jerearista](https://github.com/jerearista))

**Fixed bugs:**

- the "running\_config" api error [\#127](https://github.com/arista-eosplus/rbeapi/issues/127)
- system API may return incorrect value for iprouting when VRF present [\#123](https://github.com/arista-eosplus/rbeapi/issues/123)
- SWIX does not uninstall cleanly [\#118](https://github.com/arista-eosplus/rbeapi/issues/118)
- vlans API only returns first trunk\_group [\#113](https://github.com/arista-eosplus/rbeapi/issues/113)
- Bugfix - system :iprouting only picks up global ip routing, ignoring VRFs [\#124](https://github.com/arista-eosplus/rbeapi/pull/124) ([jerearista](https://github.com/jerearista))

**Closed issues:**

- multicast group parsing for vxlan interfaces fails [\#142](https://github.com/arista-eosplus/rbeapi/issues/142)
- Should switchconfig inject exit command at end of a section \(child\)? [\#136](https://github.com/arista-eosplus/rbeapi/issues/136)
- SwitchConfig parse needs to account for irregular spacing in config banner [\#135](https://github.com/arista-eosplus/rbeapi/issues/135)

**Merged pull requests:**

- Add json option to get\_config [\#151](https://github.com/arista-eosplus/rbeapi/pull/151) ([jerearista](https://github.com/jerearista))
- Handle more multiline config commands [\#150](https://github.com/arista-eosplus/rbeapi/pull/150) ([jerearista](https://github.com/jerearista))
- Ensure get\_config, running\_config, and startup\_config return sane output [\#149](https://github.com/arista-eosplus/rbeapi/pull/149) ([jerearista](https://github.com/jerearista))
- Switchconfig: handle non-standard indentation on banners [\#148](https://github.com/arista-eosplus/rbeapi/pull/148) ([jerearista](https://github.com/jerearista))
- add spec tests for prefix lists [\#147](https://github.com/arista-eosplus/rbeapi/pull/147) ([mrvinti](https://github.com/mrvinti))
- Add switchconfig feature [\#146](https://github.com/arista-eosplus/rbeapi/pull/146) ([jerearista](https://github.com/jerearista))
- Fix test issues [\#145](https://github.com/arista-eosplus/rbeapi/pull/145) ([jerearista](https://github.com/jerearista))
- fix parse\_instances to return the default instances and add tests [\#144](https://github.com/arista-eosplus/rbeapi/pull/144) ([rknaus](https://github.com/rknaus))
- fix issue \#142 - multicast group parsing when not configured [\#143](https://github.com/arista-eosplus/rbeapi/pull/143) ([mrvinti](https://github.com/mrvinti))
- add switchport allowed vlan range capability [\#141](https://github.com/arista-eosplus/rbeapi/pull/141) ([rknaus](https://github.com/rknaus))
- fix speed functions and add lacp port-priority functions [\#139](https://github.com/arista-eosplus/rbeapi/pull/139) ([rknaus](https://github.com/rknaus))
- Fix rpm uninstall issue \#118 [\#134](https://github.com/arista-eosplus/rbeapi/pull/134) ([jerearista](https://github.com/jerearista))
- Switchconfig rpms for chef [\#130](https://github.com/arista-eosplus/rbeapi/pull/130) ([jerearista](https://github.com/jerearista))
- Switchconfig zap empty lines [\#128](https://github.com/arista-eosplus/rbeapi/pull/128) ([jerearista](https://github.com/jerearista))
- Validate array param options [\#126](https://github.com/arista-eosplus/rbeapi/pull/126) ([websitescenes](https://github.com/websitescenes))
- Wip load interval v2 [\#122](https://github.com/arista-eosplus/rbeapi/pull/122) ([n1cn0c](https://github.com/n1cn0c))
- Created vlans set\_trunk\_groups method. [\#119](https://github.com/arista-eosplus/rbeapi/pull/119) ([devrobo](https://github.com/devrobo))

## [v0.5.1](https://github.com/arista-eosplus/rbeapi/tree/v0.5.1) (2016-02-16)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.5.0...v0.5.1)

**Implemented enhancements:**

- get\_connect should raise an error instead of returning nil if no connection is found [\#31](https://github.com/arista-eosplus/rbeapi/issues/31)
- Add build badges to the README.md [\#108](https://github.com/arista-eosplus/rbeapi/pull/108) ([jerearista](https://github.com/jerearista))

**Fixed bugs:**

- PeerEthernet regex issue [\#109](https://github.com/arista-eosplus/rbeapi/issues/109)

**Closed issues:**

- Add support for commands with input [\#100](https://github.com/arista-eosplus/rbeapi/issues/100)
- Wildcard connection config gets clobbered [\#86](https://github.com/arista-eosplus/rbeapi/issues/86)

**Merged pull requests:**

- Release 0.5.1 to master [\#117](https://github.com/arista-eosplus/rbeapi/pull/117) ([jerearista](https://github.com/jerearista))
- Release 0.5.1 [\#116](https://github.com/arista-eosplus/rbeapi/pull/116) ([jerearista](https://github.com/jerearista))
- Release 0.5.1 [\#115](https://github.com/arista-eosplus/rbeapi/pull/115) ([jerearista](https://github.com/jerearista))
- Only first trunk group was being returned. [\#114](https://github.com/arista-eosplus/rbeapi/pull/114) ([devrobo](https://github.com/devrobo))
- Add support for DEFAULT section to eapi config file. [\#111](https://github.com/arista-eosplus/rbeapi/pull/111) ([devrobo](https://github.com/devrobo))
- Remove getter for timeouts and use attr\_reader instead. [\#107](https://github.com/arista-eosplus/rbeapi/pull/107) ([websitescenes](https://github.com/websitescenes))
- Added doc for trunk groups to get. [\#106](https://github.com/arista-eosplus/rbeapi/pull/106) ([devrobo](https://github.com/devrobo))
- Tightening up documentation. [\#105](https://github.com/arista-eosplus/rbeapi/pull/105) ([websitescenes](https://github.com/websitescenes))
- Added support for setting system banners. [\#104](https://github.com/arista-eosplus/rbeapi/pull/104) ([devrobo](https://github.com/devrobo))

## [v0.5.0](https://github.com/arista-eosplus/rbeapi/tree/v0.5.0) (2016-01-12)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.4.0...v0.5.0)

**Implemented enhancements:**

- Improve VARP and VARP interface parsing [\#79](https://github.com/arista-eosplus/rbeapi/issues/79)
- Need system tests for all api modules [\#66](https://github.com/arista-eosplus/rbeapi/issues/66)
- rbeapi coding documentation incomplete [\#62](https://github.com/arista-eosplus/rbeapi/issues/62)
- switchport api should support trunk groups [\#38](https://github.com/arista-eosplus/rbeapi/issues/38)
- Need units tests for framework [\#30](https://github.com/arista-eosplus/rbeapi/issues/30)
- Need unit test to verify read and open timeout in eapi conf file override default [\#29](https://github.com/arista-eosplus/rbeapi/issues/29)
- Unit tests for switchports [\#94](https://github.com/arista-eosplus/rbeapi/pull/94) ([websitescenes](https://github.com/websitescenes))
- Ensure all parse methods are private. [\#93](https://github.com/arista-eosplus/rbeapi/pull/93) ([websitescenes](https://github.com/websitescenes))
- test timeout values [\#92](https://github.com/arista-eosplus/rbeapi/pull/92) ([websitescenes](https://github.com/websitescenes))
- Relax check on getall entries [\#91](https://github.com/arista-eosplus/rbeapi/pull/91) ([devrobo](https://github.com/devrobo))
- Update framework tests [\#90](https://github.com/arista-eosplus/rbeapi/pull/90) ([websitescenes](https://github.com/websitescenes))
- Add lacp\_mode option when setting port-channel members. [\#89](https://github.com/arista-eosplus/rbeapi/pull/89) ([devrobo](https://github.com/devrobo))
- Added support for trunk groups. [\#88](https://github.com/arista-eosplus/rbeapi/pull/88) ([devrobo](https://github.com/devrobo))
- Add basic framework tests. [\#85](https://github.com/arista-eosplus/rbeapi/pull/85) ([websitescenes](https://github.com/websitescenes))
- Address code coverage gaps [\#84](https://github.com/arista-eosplus/rbeapi/pull/84) ([websitescenes](https://github.com/websitescenes))

**Fixed bugs:**

- failure when eapi.conf is not formatted correctly [\#82](https://github.com/arista-eosplus/rbeapi/issues/82)
- Enable password setting in the .eapi.conf file not honored [\#72](https://github.com/arista-eosplus/rbeapi/issues/72)
- API interfaces should accept an lacp\_mode to configure for port-channel members [\#58](https://github.com/arista-eosplus/rbeapi/issues/58)
- Copy configuration entry before modifying with connection specific info. [\#101](https://github.com/arista-eosplus/rbeapi/pull/101) ([devrobo](https://github.com/devrobo))
- Add terminal to configure command to work around AAA issue found in p… [\#99](https://github.com/arista-eosplus/rbeapi/pull/99) ([devrobo](https://github.com/devrobo))
- Set enable password for a connection. [\#96](https://github.com/arista-eosplus/rbeapi/pull/96) ([devrobo](https://github.com/devrobo))
- Catch errors and syslog them when parsing eapi conf file. [\#95](https://github.com/arista-eosplus/rbeapi/pull/95) ([devrobo](https://github.com/devrobo))
- Ensure that nil is returned when you try to get nonexistent username. [\#83](https://github.com/arista-eosplus/rbeapi/pull/83) ([websitescenes](https://github.com/websitescenes))

**Merged pull requests:**

- Update documentation [\#97](https://github.com/arista-eosplus/rbeapi/pull/97) ([websitescenes](https://github.com/websitescenes))

## [v0.4.0](https://github.com/arista-eosplus/rbeapi/tree/v0.4.0) (2015-11-21)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.3.0...v0.4.0)

**Implemented enhancements:**

- Add users API [\#78](https://github.com/arista-eosplus/rbeapi/issues/78)
- Support BGP maximum paths [\#77](https://github.com/arista-eosplus/rbeapi/issues/77)
- Feature puppet4 swix [\#74](https://github.com/arista-eosplus/rbeapi/pull/74) ([jerearista](https://github.com/jerearista))
- Add argument checking for the track hash. [\#70](https://github.com/arista-eosplus/rbeapi/pull/70) ([devrobo](https://github.com/devrobo))
- Fix spec test issue from pull request \#61 [\#69](https://github.com/arista-eosplus/rbeapi/pull/69) ([devrobo](https://github.com/devrobo))
- Update RPM packaging to accomodate Puppet 4 AIO agent [\#68](https://github.com/arista-eosplus/rbeapi/pull/68) ([jerearista](https://github.com/jerearista))
- Update RPM packaging names, requirements, and paths due to Puppet 4 [\#65](https://github.com/arista-eosplus/rbeapi/pull/65) ([jerearista](https://github.com/jerearista))
- Add support for getting and setting maximum paths. [\#52](https://github.com/arista-eosplus/rbeapi/pull/52) ([devrobo](https://github.com/devrobo))

**Fixed bugs:**

- api interfaces get\_members\(\) passes format: instead of encoding: to enable\(\) [\#59](https://github.com/arista-eosplus/rbeapi/issues/59)
- bgp API should return nil instead of an empty hash [\#50](https://github.com/arista-eosplus/rbeapi/issues/50)
- Changed bgp.rb get routine to return nil if the config could not be o… [\#67](https://github.com/arista-eosplus/rbeapi/pull/67) ([devrobo](https://github.com/devrobo))
- Correct option to request 'text' results [\#61](https://github.com/arista-eosplus/rbeapi/pull/61) ([jerearista](https://github.com/jerearista))

**Merged pull requests:**

- Merge develop to master for Release 0.4.0 [\#81](https://github.com/arista-eosplus/rbeapi/pull/81) ([jerearista](https://github.com/jerearista))
- Release 0.4.0 [\#80](https://github.com/arista-eosplus/rbeapi/pull/80) ([jerearista](https://github.com/jerearista))
- Update rubocop version and rectify related test failures. [\#76](https://github.com/arista-eosplus/rbeapi/pull/76) ([websitescenes](https://github.com/websitescenes))
- Add method to enable ip routing to the system API [\#75](https://github.com/arista-eosplus/rbeapi/pull/75) ([websitescenes](https://github.com/websitescenes))
- Added vrrp api module and unit tests. [\#64](https://github.com/arista-eosplus/rbeapi/pull/64) ([devrobo](https://github.com/devrobo))
- Adding feature routemap [\#63](https://github.com/arista-eosplus/rbeapi/pull/63) ([websitescenes](https://github.com/websitescenes))
- varp and varp interfaces update. [\#60](https://github.com/arista-eosplus/rbeapi/pull/60) ([websitescenes](https://github.com/websitescenes))
- Fixed comment for value param for set\_lacp\_timeout method. [\#57](https://github.com/arista-eosplus/rbeapi/pull/57) ([devrobo](https://github.com/devrobo))
- Feature user updates [\#56](https://github.com/arista-eosplus/rbeapi/pull/56) ([websitescenes](https://github.com/websitescenes))
- Update max\_paths to maximum\_paths and max\_ecmp\_paths to maximum\_ecmp\_… [\#55](https://github.com/arista-eosplus/rbeapi/pull/55) ([websitescenes](https://github.com/websitescenes))
- Fixed issues on the new bgp create call. [\#54](https://github.com/arista-eosplus/rbeapi/pull/54) ([devrobo](https://github.com/devrobo))
- Added support for getting users information. [\#53](https://github.com/arista-eosplus/rbeapi/pull/53) ([devrobo](https://github.com/devrobo))
- add dry-run mode [\#42](https://github.com/arista-eosplus/rbeapi/pull/42) ([kakkotetsu](https://github.com/kakkotetsu))

## [v0.3.0](https://github.com/arista-eosplus/rbeapi/tree/v0.3.0) (2015-08-24)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.2.0...v0.3.0)

**Fixed bugs:**

- rbeapi exits if $HOME is not set [\#46](https://github.com/arista-eosplus/rbeapi/issues/46)

**Merged pull requests:**

- Release 0.3.0 to master [\#51](https://github.com/arista-eosplus/rbeapi/pull/51) ([jerearista](https://github.com/jerearista))
- Release 0.3.0 [\#49](https://github.com/arista-eosplus/rbeapi/pull/49) ([jerearista](https://github.com/jerearista))
- Only search home directory if HOME is defined ISSUE \#46 [\#48](https://github.com/arista-eosplus/rbeapi/pull/48) ([devrobo](https://github.com/devrobo))
- set\_shutdown needs to negate the enable option. [\#47](https://github.com/arista-eosplus/rbeapi/pull/47) ([devrobo](https://github.com/devrobo))
- Feature staticroutes [\#45](https://github.com/arista-eosplus/rbeapi/pull/45) ([jerearista](https://github.com/jerearista))
- Broaden the regex matching for portchannel member interfaces [\#44](https://github.com/arista-eosplus/rbeapi/pull/44) ([jerearista](https://github.com/jerearista))
- Update rpm requires sections for rbeapi [\#43](https://github.com/arista-eosplus/rbeapi/pull/43) ([jerearista](https://github.com/jerearista))
- Added support for BGP along with unit tests. [\#41](https://github.com/arista-eosplus/rbeapi/pull/41) ([devrobo](https://github.com/devrobo))
- Eliminate overloading value option in command\_builder. [\#39](https://github.com/arista-eosplus/rbeapi/pull/39) ([devrobo](https://github.com/devrobo))

## [v0.2.0](https://github.com/arista-eosplus/rbeapi/tree/v0.2.0) (2015-07-08)
[Full Changelog](https://github.com/arista-eosplus/rbeapi/compare/v0.1.0...v0.2.0)

**Implemented enhancements:**

- Add \[connection:\*\] to eapi.conf syntax [\#18](https://github.com/arista-eosplus/rbeapi/issues/18)
- can't rake all\_rpms [\#11](https://github.com/arista-eosplus/rbeapi/issues/11)
- add read\_timeout and open\_timeout to client.rb [\#10](https://github.com/arista-eosplus/rbeapi/issues/10)
- Add netaddr rubygem rpm [\#35](https://github.com/arista-eosplus/rbeapi/pull/35) ([jerearista](https://github.com/jerearista))
- Fix RPM packaging for Ubuntu systems. Fixes \#11 [\#14](https://github.com/arista-eosplus/rbeapi/pull/14) ([jerearista](https://github.com/jerearista))

**Fixed bugs:**

- rbeapi swix/rpms fail to install completely on EOS [\#34](https://github.com/arista-eosplus/rbeapi/issues/34)
- interfaces API may appear to return duplicate port-channel members on MLAG interfaces [\#16](https://github.com/arista-eosplus/rbeapi/issues/16)
- connection profile name is not copied to host attribute [\#6](https://github.com/arista-eosplus/rbeapi/issues/6)
- NoMethodError when accessing a vlan-name containing a '-' character [\#5](https://github.com/arista-eosplus/rbeapi/issues/5)

**Merged pull requests:**

- Release 0.2.0 to master [\#37](https://github.com/arista-eosplus/rbeapi/pull/37) ([jerearista](https://github.com/jerearista))
- Release 0.2.0 version and doc updates [\#36](https://github.com/arista-eosplus/rbeapi/pull/36) ([jerearista](https://github.com/jerearista))
- Change class name and hash key names. [\#33](https://github.com/arista-eosplus/rbeapi/pull/33) ([devrobo](https://github.com/devrobo))
- name path through if default connection is used [\#32](https://github.com/arista-eosplus/rbeapi/pull/32) ([kakkotetsu](https://github.com/kakkotetsu))
- Added API for standard ACLs with unit and system test. [\#28](https://github.com/arista-eosplus/rbeapi/pull/28) ([devrobo](https://github.com/devrobo))
- Add \[connection:\*\] to eapi.conf syntax Issue \#18 [\#27](https://github.com/arista-eosplus/rbeapi/pull/27) ([devrobo](https://github.com/devrobo))
- Add read\_timeout and open\_timeout to client.rb Issue 10 [\#26](https://github.com/arista-eosplus/rbeapi/pull/26) ([devrobo](https://github.com/devrobo))
- Set host key to connection profile name if host key not set. ISSUE 6 [\#25](https://github.com/arista-eosplus/rbeapi/pull/25) ([devrobo](https://github.com/devrobo))
- Changed default transport to https to match README.md [\#24](https://github.com/arista-eosplus/rbeapi/pull/24) ([devrobo](https://github.com/devrobo))
- Fixes to the rbeabi library [\#23](https://github.com/arista-eosplus/rbeapi/pull/23) ([devrobo](https://github.com/devrobo))
- Cleanup spec tests, all tests are passing. [\#21](https://github.com/arista-eosplus/rbeapi/pull/21) ([devrobo](https://github.com/devrobo))
- Doc fixes [\#20](https://github.com/arista-eosplus/rbeapi/pull/20) ([devrobo](https://github.com/devrobo))
- Addressed RuboCop reported issues. [\#19](https://github.com/arista-eosplus/rbeapi/pull/19) ([devrobo](https://github.com/devrobo))
- Fixes \#16 - Change port-channel members regex to anchor on word-boundary. [\#17](https://github.com/arista-eosplus/rbeapi/pull/17) ([jerearista](https://github.com/jerearista))
- Rubocop driven cleanup. Spec tests still need to be fixed. [\#12](https://github.com/arista-eosplus/rbeapi/pull/12) ([devrobo](https://github.com/devrobo))
- add HTTP read\_timeout [\#9](https://github.com/arista-eosplus/rbeapi/pull/9) ([kakkotetsu](https://github.com/kakkotetsu))
- Add support for spanning tree portfast\_type. [\#8](https://github.com/arista-eosplus/rbeapi/pull/8) ([devrobo](https://github.com/devrobo))
- Fix typo in set\_flowcontrol method. [\#7](https://github.com/arista-eosplus/rbeapi/pull/7) ([devrobo](https://github.com/devrobo))
- Feature - generate RPMs and instructions for SWIX files [\#4](https://github.com/arista-eosplus/rbeapi/pull/4) ([jerearista](https://github.com/jerearista))
- Fix a couple typos, minor formatting in README.md [\#3](https://github.com/arista-eosplus/rbeapi/pull/3) ([brandt](https://github.com/brandt))
- Fix missing OpenSSL require [\#2](https://github.com/arista-eosplus/rbeapi/pull/2) ([brandt](https://github.com/brandt))

## [v0.1.0](https://github.com/arista-eosplus/rbeapi/tree/v0.1.0) (2015-02-25)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*