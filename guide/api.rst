Copyright (c) 2014, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Aaa class manages Authorization, Authentication and Accounting (AAA)
on an EOS node.

get returns a hash of all Aaa resources.

@example { : { : { type: , servers: }, : { type: , servers: } } }

@return [Hash<Symbol, Object>] Returns the Aaa resources as a Hash. If
no Aaa resources are found, an empty hash is returned.

Returns an object node for working with AaaGroups class.

The AaaGroups class manages the server groups on an EOS node. Regular
expression that parses the radius servers from the aaa group server
radius configuration block. Regular expression that parses the tacacs
servers from the aaa group server tacacs+ configuration block.

get returns the aaa server group resource hash that describes the
current configuration for the specified server group name.

@example { type: , servers: }

@param name [String] The server group name to return from the nodes
current running configuration. If the name is not configured a nil
object is returned.

@return [nil, Hash<Symbol, Object>] Returns the resource hash for the
specified name. If the name does not exist, a nil object is returned.
block = get\_block("aaa group server ([^\\s]+) {name}")

getall returns a aaa server groups hash.

@example { : { type: , servers: }, : { type: , servers: } }

@return [Hash<Symbol, Object>] Returns the resource hashes for
configured aaa groups. If none exist, a nil object is returned.

parse\_type scans the specified configuration block and returns the
server group type as either 'tacacs' or 'radius'. The type value is
expected to always be present in the config.

@api private

@param config [String] The aaa server group block configuration for the
group name to parse.

@return [Hash<Symbol, Object>] Resource hash attribute.

parse\_servers scans the specified configuraiton block and returns the
list of servers configured for the group. If there are no servers
configured for the group the servers value will return an empty array.

@api private

@see parse\_radius\_server @see parse\_tacacs\_server

@param config [String] The aaa server group block configuration for the
group name to parse.

@param type [String] The aaa server block type. Valid values are either
radius or tacacs+.

@return [Hash<Symbol, Object>] Resource hash attribute

parse\_radius\_server scans the provide configuration block and returns
the list of servers configured. The configuration block is expected to
be a radius configuration block. If there are no servers configured for
the group the servers value will return an empty array.

@api private

@param config [String] The aaa server group block configuration for the
group name to parse

@return [Hash<Symbol, Object>] resource hash attribute

parse\_tacacs\_server scans the provided configuration block and returns
the list of configured servers. The configuration block is expected to
be a tacacs configuration block. If there are no servers configured for
the group the servers value will return an empty array.

@api private

@param config [String] The aaa server group block configuration for the
group name to parse.

@return [Hash<Symbol, Object>] Resource hash attribute.

find\_type is a utility method to find the type of aaa server group for
the specified name. This method will scan the current running
configuration on the node and return the server group type as either
'radius' or 'tacacs+'. If the server group is not configured, then nil
will be returned.

@api private

@param name [String] The aaa server group name to find in the config and
return the type value for.

@return [nil, String] Returns either the type name as 'radius' or
'tacacs+' or nil if the server group is not configured. mdata = /aaa
group server ([^\\s]+) {name}/.match(config)

create adds a new aaa group server to the nodes current configuration.
If the specified name and type are already created then this method will
return successfully. If the name is configured but the type is
different, this method will not return successfully (returns false).

@since eos\_version 4.13.7M

commands aaa group server

@param name [String] The name of the aaa group server to create in the
nodes running configuration

@param type [String] The type of aaa group server to create in the nodes
running configuration. Valid values include 'radius' or 'tacacs+'

@return [Boolean] returns true if the commands complete successfully
configure ["aaa group server {type} {name}", 'exit']

delete removes a current aaa server group from the nodes current
configuration. This method will automatically determine the server group
type based on the name. If the name is not configured in the nodes
current configuration, this method will return successfully.

@since eos\_version 4.13.7M

commands no aaa group server [radius \| tacacs+]

@param name [String] The name of the aaa group server to create in the
nodes running configuration.

@return [Boolean] Returns true if the commands complete successfully.
configure "no aaa group server {type} {name}"

set\_servers configures the set of servers for a specified aaa server
group. This is an atomic operation that first removes all current
servers and then adds the new servers back. If any of the servers failes
to be removed or added, this method will return unsuccessfully.

@see remove\_server @see add\_server

@param name [String] The name of the aaa group server to add the new
server configuration to.

@param servers [String] The IP address or host name of the server to add
to the configuration

@return [Boolean] Returns true if the commands complete successfully

add\_server adds a new server to the specified aaa server group. If the
server is already configured in the list of servers, this method will
still return successfully.

@see add\_radius\_server @see add\_tacacs\_server

@param name [String] The name of the aaa group server to add the new
server configuration to.

@param server [String] The IP address or host name of the server to add
to the configuration.

@param opts [Hash] Optional configuration parameters.

@return [Boolean] Returns true if the commands complete successfully.

add\_radius\_server adds a new radius server to the nodes current
configuration. If the server already exists in the specified group name
this method will still return successfully.

@since eos\_version 4.13.7M

commmands aaa group server radius server [acct-port ] [auth-port ] [vrf
]

@param name [String] The name of the aaa group server to add the new
server configuration to.

@param server [String] The IP address or host name of the server to add
to the configuration.

@param opts [Hash] Optional configuration parameters.

@return [Boolean] Returns true if the commands complete successfully.
order of command options matter here! server = "server {server} " server
<< "auth-port {opts[:auth\_port]} " if opts[:auth\_port] server <<
"acct-port {opts[:acct\_port]} " if opts[:acct\_port] server << "vrf
{opts[:vrf]}" if opts[:vrf] configure ["aaa group server radius {name}",
server, 'exit']

add\_tacacs\_server adds a new tacacs server to the nodes current
configuration. If the server already exists in the specified group name
this method will still return successfully.

@since eos\_version 4.13.7M

commmands aaa group server tacacs+ server [acct-port ] [auth-port ] [vrf
]

@param name [String] The name of the aaa group server to add the new
server configuration to.

@param server [String] The IP address or host name of the server to add
to the configuration.

@param opts [Hash] Optional configuration parameters.

@return [Boolean] Returns true if the commands complete successfully.
order of command options matter here! server = "server {server} " server
<< "vrf {opts[:vrf]} " if opts[:vrf] server << "port {opts[:port]} " if
opts[:port] configure ["aaa group server tacacs+ {name}", server,
'exit']

remove\_server deletes an existing server from the specified aaa server
group. If the specified server is not configured in the specified server
group, this method will still return true.

eos\_version 4.13.7M

commands aaa group server [radius \| tacacs+] no server

@param name [String] The name of the aaa group server to remove.

@param server [String] The IP address or host name of the server.

@param opts [Hash] Optional configuration parameters.

@return [Boolean] returns true if the commands complete successfully.
server = "no server {server} " server << "vrf {opts[:vrf]}" if
opts[:vrf] configure ["aaa group server {type} {name}", server, 'exit']

Copyright (c) 2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Acl class manages the set of standard ACLs.

get returns the specified ACL from the nodes current configuration.

@example { : { seqno: , action: , srcaddr: , srcprefixle: , log: }, : {
seqno: , action: , srcaddr: , srcprefixle: , log: }, ... }

@param name [String] The ACL name.

@return [nil, Hash<Symbol, Object>] Returns the ACL resource as a Hash.
Returns nil if name does not exist. config = get\_block("ip access-list
standard {name}")

getall returns the collection of ACLs from the nodes running
configuration as a hash. The ACL resource collection hash is keyed by
the ACL name.

@example { : { : { seqno: , action: , srcaddr: , srcprefixle: , log: },
: { seqno: , action: , srcaddr: , srcprefixle: , log: }, ... }, : { : {
seqno: , action: , srcaddr: , srcprefixle: , log: }, : { seqno: ,
action: , srcaddr: , srcprefixle: , log: }, ... }, ... }

@return [nil, Hash<Symbol, Object>] Returns a hash that represents the
entire ACL collection from the nodes running configuration. If there are
no ACLs configured, this method will return an empty hash.

mask\_to\_prefixlen converts a subnet mask from dotted decimal to bit
length.

@param mask [String] The dotted decimal subnet mask to convert.

@return [String] The subnet mask as a valid prefix length.

parse\_entries scans the nodes configurations and parses the entries
within an ACL.

@api private

@param config [String] The switch config.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

create will create a new ACL resource in the nodes current configuration
with the specified name. If the create method is called and the ACL
already exists, this method will still return true. The ACL will not
have any entries. Use add\_entry to add entries to the ACL.

@since eos\_version 4.13.7M

commands ip access-list standard

@param name [String] The ACL name to create on the node. Must begin with
an alphabetic character. Cannot contain spaces or quotation marks.

@return [Boolean] Returns true if the command completed successfully.
configure("ip access-list standard {name}")

delete will delete an existing ACL resource from the nodes current
running configuration. If the delete method is called and the ACL does
not exist, this method will succeed.

@since eos\_version 4.13.7M

commands no ip access-list standard

@param name [String] The ACL name to delete on the node.

@return [Boolean] Returns true if the command completed successfully.
configure("no ip access-list standard {name}")

default will configure the ACL using the default keyword. This command
has the same effect as deleting the ACL from the nodes running
configuration.

@since eos\_version 4.13.7M

commands default no ip access-list standard

@param name [String] The ACL name to set to the default value on the
node.

@return [Boolean] Returns true if the command complete successfully
configure("default ip access-list standard {name}")

build\_entry will build the commands to add an entry.

@api private

@param entry [Hash] the options for the entry.

@option entry seqno [String] The sequence number of the entry in the ACL
to add. Default is nil, will be assigned.

@option entry action [String] The action triggered by the ACL. Valid
values are 'permit', 'deny', or 'remark'.

@option entry addr [String] The IP address to permit or deny.

@option entry prefixlen [String] The prefixlen for the IP address.

@option entry log [Boolean] Triggers an informational log message to the
console about the matching packet.

@return [String] Returns commands to create an entry. cmds =
"{entry[:seqno]} " if entry[:seqno] cmds << "{entry[:action]}
{entry[:srcaddr]}/{entry[:srcprefixlen]}"

update\_entry will update an entry, identified by the seqno in the ACL
specified by name, with the passed in parameters.

@since eos\_version 4.13.7M

@param name [String] The ACL name to update on the node.

@param entry [Hash] the options for the entry.

@option entry seqno [String] The sequence number of the entry in the ACL
to update.

@option entry action [String] The action triggered by the ACL. Valid
values are 'permit', 'deny', or 'remark'.

@option entry addr [String] The IP address to permit or deny.

@option entry prefixlen [String] The prefixlen for the IP address.

@option entry log [Boolean] Triggers an informational log message to the
console about the matching packet.

@return [Boolean] Returns true if the command complete successfully.
cmds = ["ip access-list standard {name}"] cmds << "no {entry[:seqno]}"

add\_entry will add an entry to the specified ACL with the passed in
parameters.

@since eos\_version 4.13.7M

@param name [String] The ACL name to add an entry to on the node.

@param entry [Hash] the options for the entry.

@option entry action [String] The action triggered by the ACL. Valid
values are 'permit', 'deny', or 'remark'.

@option entry addr [String] The IP address to permit or deny.

@option entry prefixlen [String] The prefixlen for the IP address.

@option entry log [Boolean] Triggers an informational log message to the
console about the matching packet.

@return [Boolean] Returns true if the command complete successfully.
cmds = ["ip access-list standard {name}"]

remove\_entry will remove the entry specified by the seqno for the ACL
specified by name.

@since eos\_version 4.13.7M

@param name [String] The ACL name to update on the node.

@param seqno [String] The sequence number of the entry in the ACL to
remove.

@return [Boolean] Returns true if the command complete successfully.
cmds = ["ip access-list standard {name}", "no {seqno}", 'exit']

Copyright (c) 2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Eos is the toplevel namespace for working with Arista EOS nodes.

Api is module namespace for working with the EOS command API.

The Bgp class implements global BGP router configuration.

get returns the BGP routing configuration from the nodes current
configuration.

@example { bgp\_as: , router\_id: , shutdown: , maximum\_paths: ,
maximum\_ecmp\_paths: networks: [ { prefix: , masklen: , route\_map: },
{ prefix: , masklen: , route\_map: } ], neighbors: { name: {
peer\_group: , remote\_as: , send\_community: , shutdown: , description:
, next\_hop\_selp: , route\_map\_in: , route\_map\_out: }, name: {
peer\_group: , remote\_as: , send\_community: , shutdown: , description:
, next\_hop\_selp: , route\_map\_in: , route\_map\_out: }, ... } }

@return [nil, Hash<Symbol, Object>] Returns the BGP resource as a Hash.

parse\_bgp\_as scans the BGP routing configuration for the AS number.
Defined as a class method. Used by the BgpNeighbors class below.

@param config [String] The switch config.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_router\_id scans the BGP routing configuration for the router ID.

@api private

@param config [String] The switch config.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_shutdown scans the BGP routing configuration for the shutdown
status.

@api private

@param config [String] The switch config.

@return [Hash<Symbol, Object>] resource hash attribute. Returns true if
shutdown, false otherwise.

parse\_maximum\_paths scans the BGP routing configuration for the
maximum paths and maximum ecmp paths.

@api private

@param config [String] The switch config.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_networks scans the BGP routing configuration for all the network
entries.

@api private

@param config [String] The switch config.

@return [Array<Hash>] Single element hash with Array of network hashes.

create will create a new instance of BGP routing on the node. Optional
parameters can be passed in to initialize BGP specific settings.

commands router bgp

@param bgp\_as [String] The BGP autonomous system number to be
configured for the local BGP routing instance.

@param opts [hash] Optional keyword arguments.

@option opts router\_id [String] The BGP routing process router-id
value. When no ID has been specified (i.e. value not set), the local
router ID is set to the following: \* The loopback IP address when a
single loopback interface is configured. \* The loopback with the
highest IP address when multiple loopback interfaces are configured. \*
The highest IP address on a physical interface when no loopback
interfaces are configure

@option opts maximum\_paths [Integer] Maximum number of equal cost
paths.

@option opts maximum\_ecmp\_paths [Integer] Maximum number of installed
ECMP routes. The maximum\_paths option must be set if
maximum\_ecmp\_paths is set.

@option opts enable [Boolean] If true then the BGP router is enabled. If
false then the BGP router is disabled.

@return [Boolean] returns true if the command completed successfully.
cmds = ["router bgp {bgp\_as}"] cmds << "router-id {opts[:router\_id]}"
if opts.key?(:router\_id) cmd = "maximum-paths {opts[:maximum\_paths]}"
cmd << " ecmp {opts[:maximum\_ecmp\_paths]}"

delete will delete the BGP routing instance from the node.

commands no router bgp

@return [Boolean] Returns true if the command completed successfully.
configure("no router bgp {config[:bgp\_as]}")

default will configure the BGP routing using the default keyword. This
command has the same effect as deleting the BGP routine instance from
the nodes running configuration.

commands default router bgp

@return [Boolean] returns true if the command complete successfully
configure("default router bgp {config[:bgp\_as]}")

configure\_bgp adds the command to go to BGP config mode. Then it adds
the passed in command. The commands are then passed on to configure.

@api private

@param cmd [String] Command to run under BGP mode.

@return [Boolean] Returns true if the command complete successfully.
cmds = ["router bgp {bgp\_as[:bgp\_as]}", cmd]

set\_router\_id sets the router\_id for the BGP routing instance.

commands router bgp {no \| default} router-id

@param opts [hash] Optional keyword arguments

@option opts value [String] The BGP routing process router-id value.
When no ID has been specified (i.e. value not set), the local router ID
is set to the following: \* The loopback IP address when a single
loopback interface is configured. \* The loopback with the highest IP
address when multiple loopback interfaces are configured. \* The highest
IP address on a physical interface when no loopback interfaces are
configure

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the router-id using the default
keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_shutdown configures the administrative state for the global BGP
routing process. The value option is not used by this method.

commands router bgp {no \| default} shutdown

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] If enable is true then the BGP routing
process is administratively enabled and if enable is False then the BGP
routing process is administratively disabled.

@option opts default [Boolean] Configure the router-id using the default
keyword.

@return [Boolean] Returns true if the command complete successfully.
Shutdown semantics are opposite of enable semantics so invert enable

set\_maximum\_paths sets the maximum number of equal cost paths and the
maximum number of installed ECMP routes.

commands router bgp {no \| default} maximum-paths [ecmp ]

@param maximum\_paths [Integer] Maximum number of equal cost paths.

@param maximum\_ecmp\_paths [Integer] Maximum number of installed ECMP
routes.

@param opts [hash] Optional keyword arguments

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the maximum paths using the
default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "maximum-paths {maximum\_paths} ecmp {maximum\_ecmp\_paths}"

add\_network creates a new instance of a BGP network on the node.

commands router bgp network / route-map

@param prefix [String] The IPv4 prefix to configure as part of the
network statement. The value must be a valid IPv4 prefix.

@param masklen [String] The IPv4 subnet mask length in bits. The masklen
must be in the valid range of 1 to 32.

@param route\_map [String] The route-map name to apply to the network
statement when configured.

@return [Boolean] Returns true if the command complete successfully. cmd
= "network {prefix}/{masklen}" cmd << " route-map {route\_map}" if
route\_map

remove\_network removes the instance of a BGP network on the node.

commands router bgp {no} shutdown

@param prefix [String] The IPv4 prefix to configure as part of the
network statement. The value must be a valid IPv4 prefix.

@param masklen [String] The IPv4 subnet mask length in bits. The masklen
must be in the valid range of 1 to 32.

@param route\_map [String] The route-map name to apply to the network
statement when configured.

@return [Boolean] Returns true if the command complete successfully. cmd
= "no network {prefix}/{masklen}" cmd << " route-map {route\_map}" if
route\_map

The BgpNeighbors class implements BGP neighbor configuration

get returns a single BGP neighbor entry from the nodes current
configuration.

@example { peer\_group: , remote\_as: , send\_community: , shutdown: ,
description: next\_hop\_self: route\_map\_in: route\_map\_out: }

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [nil, Hash<Symbol, Object>] Returns the BGP neighbor resource as
a Hash.

getall returns the collection of all neighbor entries for the BGP router
instance.

@example { : { peer\_group: , remote\_as: , send\_community: , shutdown:
, description: next\_hop\_self: route\_map\_in: route\_map\_out: }, : {
peer\_group: , remote\_as: , send\_community: , shutdown: , description:
next\_hop\_self: route\_map\_in: route\_map\_out: }, ... }

@return [nil, Hash<Symbol, Object>] Returns a hash that represents the
entire BGP neighbor collection from the nodes running configuration. If
there a BGP router is not configured or contains no neighbor entries
then this method will return an empty hash.

parse\_peer\_group scans the BGP neighbor entries for the peer group.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/neighbor {name} peer-group ([^\\s]+)/)

parse\_remote\_as scans the BGP neighbor entries for the remote AS.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute value
= config.scan(/neighbor {name} remote-as (:raw-latex:`\d`+)/)

parse\_send\_community scans the BGP neighbor entries for the remote AS.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/no neighbor {name} send-community/)

parse\_shutdown scans the BGP neighbor entries for the remote AS.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Resource hash attribute. Returns true if
shutdown, false otherwise. value = config.scan(/no neighbor {name}
shutdown/)

parse\_description scans the BGP neighbor entries for the description.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/neighbor {name} description (.\*)$/)

parse\_next\_hop\_self scans the BGP neighbor entries for the next hop
self.

@api private

@param config [String] The switch config. @param name [String] The name
of the BGP neighbor to manage. This value can be either an IPv4 address
or string (in the case of managing a peer group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/no neighbor {name} next-hop-self/)

parse\_route\_map\_in scans the BGP neighbor entries for the route map
in.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/neighbor {name} route-map ([^\\s]+) in/)

parse\_route\_map\_out scans the BGP neighbor entries for the route map
in.

@api private

@param config [String] The switch config.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
value = config.scan(/neighbor {name} route-map ([^\\s]+) out/)

configure\_bgp adds the command to go to BGP config mode. Then it adds
the passed in command. The commands are then passed on to configure.

@api private

@param cmd [String] Command to run under BGP mode.

@return [Boolean] Returns true if the command complete successfully.
cmds = ["router bgp {bgp\_as[:bgp\_as]}", cmd]

create will create a new instance of a BGP neighbor on the node. The
neighbor is created in the shutdown state and then enabled.

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Boolean] Returns true if the command completed successfully.

delete will delete the BGP neighbor from the node.

commands no neighbor or no neighbor peer-group

@param name [String] The name of the BGP neighbor to manage. This value
can be either an IPv4 address or string (in the case of managing a peer
group).

@return [Boolean] Returns true if the command completed successfully.
cmd = "no neighbor {name}" cmd = "no neighbor {name} peer-group"

neigh\_command\_builder for neighbors which calls command\_builder.

@param name [String] The name of the BGP neighbor to manage.

@param cmd [String] The command portion of the neighbor command.

@param opts [hash] Optional keyword arguments.

@option opts value [String] Value being set.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the command using the default
keyword.

@return [String] Returns built command string.
command\_builder("neighbor {name} {cmd}", opts)

set\_peer\_group creates a BGP static peer group name.

commands router bgp {no \| default} neighbor peer-group

@param name [String] The IP address of the neighbor.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The group name.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_remote\_as configures the expected AS number for a neighbor (peer).

commands router bgp {no \| default} neighbor remote-as

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The remote as-id.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_shutdown disables the specified neighbor. The value option is not
used by this method.

commands router bgp {no \| default} neighbor shutdown

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts enable [String] True enables the specified neighbor. False
disables the specified neighbor.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.
Shutdown semantics are opposite of enable semantics so invert enable.

set\_send\_community configures the switch to send community attributes
to the specified BGP neighbor. The value option is not used by this
method.

commands router bgp {no \| default} neighbor send-community

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts enable [String] True enables the feature. False disables
the feature.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_next\_hop\_self configures the switch to list its address as the
next hop in routes that it advertises to the specified BGP-speaking
neighbor or neighbors in the specified peer group. The value option is
not used by this method.

commands router bgp {no \| default} neighbor next-hop-self

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts enable [String] True enables the feature. False disables
the feature.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_route\_map\_in command applies a route map to inbound BGP routes.

commands router bgp {no \| default} neighbor route-map in

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts value [String] Name of a route map.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_route\_map\_out command applies a route map to outbound BGP routes.

commands router bgp {no \| default} neighbor route-map out

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts value [String] Name of a route map.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

set\_description associates descriptive text with the specified peer or
peer group.

commands router bgp {no \| default} neighbor description

@param name [String] The IP address or name of the peer group.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The description string.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer group using the
default keyword.

@return [Boolean] Returns true if the command complete successfully.

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Dns class manages DNS settings on an EOS node.

get returns the DNS resource.

@example { "domain\_name": , "name\_servers": array, "domain\_list":
array }

@return [Hash] A Ruby hash object that provides the SNMP settings as key
/ value pairs.

parse\_domain\_name parses the domain-name from config.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_name\_servers parses the name-server values from config.

@api private

@return [Hash<Symbol, Array>] Returns the resource hash attribute.

parse\_domain\_list parses the domain-list from config.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

Configure the domain-name value in the running-config.

@param opts [Hash] The configuration parameters.

@option opts value [string] The value to set the domain-name to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] Returns true if the command completed successfully.

set\_name\_servers configures the set of name servers that eos will use
to resolve dns queries. If the enable option is false, then the
name-server list will be configured using the no keyword. If the default
option is specified, then the name server list will be configured using
the default keyword. If both options are provided the keyword option
will take precedence.

@since eos\_version 4.13.7M

commands ip name-server no ip name-server default ip name-server

@param [Hash] opts The configuration parameters.

@option opts value [string] The set of name servers to configure on the
node. The list of name servers will be replace in the nodes running
configuration by the list provided in value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option default [Boolean] Configures the ip name-servers using the
default keyword argument. Default takes precedence over enable.

@return [Boolean] Returns true if the commands completed successfully.
cmds << "ip name-server {srv}"

add\_name\_server adds an ip name-server.

@param server [String] The name of the ip name-server to create.

@return [Boolean] Returns true if the command completed successfully.
configure "ip name-server {server}"

remove\_name\_server removes the specified ip name-server.

@param server [String] The name of the ip name-server to remove.

@return [Boolean] Returns true if the command completed successfully.
configure "no ip name-server {server}"

set\_domain\_list configures the set of domain names to search when
making dns queries for the FQDN. If the enable option is set to false,
then the domain-list will be configured using the no keyword. If the
default option is specified, then the domain list will be configured
using the default keyword. If both options are provided the default
keyword option will take precedence.

@since eos\_version 4.13.7M

commands ip domain-list no ip domain-list default ip domain-list

@option value [Array] The set of domain names to configure on the node.
The list of domain names will be replace in the nodes running
configuration by the list provided in value.

@option default [Boolean] Configures the ip domain-list using the
default keyword argument.

@return [Boolean] Returns true if the commands completed successfully.
cmds << "default ip domain-list {name}" cmds << "no ip domain-list
{name}" cmds << "ip domain-list {name}"

add\_domain\_list adds an ip domain-list.

@param name [String] The name of the ip domain-list to add.

@return [Boolean] Returns true if the command completed successfully.
configure "ip domain-list {name}"

remove\_domain\_list removes a specified ip domain-list.

@param name [String] The name of the ip domain-list to remove.

@return [Boolean] Returns true if the command completed successfully.
configure "no ip domain-list {name}"

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Interfaces class manages all physical and logical interfaces on an
EOS node.

get returns a hash of interface configurations for the given name.

@example { name: , type: , description: , shutdown: }

@param name [String] The interface name to return a resource for from
the nodes configuration.

@return [nil, Hash<Symbol, Object>] Returns the interface resource as a
Hash. If the specified name is not found in the nodes current
configuration a nil object is returned.

getall returns a hash of interface configurations.

@example { : { name: , type: , description: , shutdown: , ... }, : {
name: , type: , description: , shutdown: , ... }, ... }

@return [Hash<Symbol, Object>] Returns the interface resources as a
Hash. If none exist in the nodes current configuration an empty hash is
returned.

get\_instance returns an interface instance for the given name.

@param name [String] The interface name to return an instance for.

@return [Object] Returns the interface instance as an Object.

The BaseInterface class extends Entity and provides an implementation
that is common to all interfaces configured in EOS.

get returns the specified interface resource hash that represents the
node's current interface configuration. The BaseInterface class provides
all the set of attributes that are common to all interfaces in EOS. This
method will return an interface type of generic.

@example { name: type: 'generic' description: shutdown: [true, false] }

@param name [String] The name of the interface to return from the
running-configuration.

@return [nil, Hash<String, Object>] Returns a hash of the interface
properties if the interface name was found in the running configuration.
If the interface was not found, nil is returned. config =
get\_block("^interface {name}")

parse\_description scans the provided configuration block and parses the
description value if it exists in the configuration. If the description
value is not configured, then the DEFALT\_INTF\_DESCRIPTION value is
returned. The hash returned by this method is intended to be merged into
the interface resource hash returned by the get method.

@api private

@param config [String] The configuration block retrieved from the nodes
current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_shutdown scans the provided configuration block and parses the
shutdown value. If the shutdown value is configured then true is
returned as its value otherwise false is returned. The hash returned by
this method is intended to be merged into the interface resource hash
returned by the get method.

@api private

@param config [String] The configuration block retrieved from the nodes
current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

create will create a new interface resource in the node's current
configuration with the specified interface name. If the create method is
called and the interface already exists, this method will return
successful.

@since eos\_version 4.13.7M

@param value [String] The interface name to create on the node. The
interface name must be the full interface identifier (ie Loopback, not
Lo).

@return [Boolean] Returns true if the command completed successfully.
configure("interface {value}")

delete will delete an existing interface resource in the node's current
configuration with the specified interface name. If the delete method is
called and interface does not exist, this method will return successful.

@since eos\_version 4.13.7M

@param value [String] The interface name to delete from the node. The
interface name must be the full interface identifier (ie Loopback, no
Lo).

@return [Boolean] Returns true if the command completed successfully.
configure("no interface {value}")

default will configure the interface using the default keyword. For
virtual interfaces this is equivalent to deleting the interface. For
physical interfaces, the entire interface configuration will be set to
defaults.

@since eos\_version 4.13.7M

@param value [String] The interface name to default in the node. The
interface name must be the full interface identifier (ie Loopback, not
Lo).

@return [Boolean] Returns true if the command completed successfully.
configure("default interface {value}")

set\_description configures the description value for the specified
interface name in the nodes running configuration. If the enable keyword
is false then the description value is negated using the no keyword. If
the default keyword is set to true, then the description value is
defaulted using the default keyword. The default keyword takes
precedence over the enable keyword if both are provided.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration to.
The name value must be the full interface identifier.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The value to configure the description to in
the node's configuration.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the interface description using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_shutdown configures the administrative state of the specified
interface in the node. If the enable keyword is false, then the
interface is administratively disabled. If the enable keyword is true,
then the interface is administratively enabled. If the default keyword
is set to true, then the interface shutdown value is configured using
the default keyword. The default keyword takes precedence over the
enable keyword if both are provided.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration to.
The name value must be the full interface identifier.

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] True if the interface should be
administratively enabled or false if the interface should be
administratively disabled.

@option opts default [Boolean] Configure the interface shutdown using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.
Shutdown semantics are opposite of enable semantics so invert enable.

The EthernetInterface class manages all Ethernet interfaces on an EOS
node.

get returns the specified Ethernet interface resource hash that
represents the interface's current configuration in the node.

@example { name: , type: , description: , shutdown: , speed: , forced: ,
sflow: , flowcontrol\_send: , flowcontrol\_receive: }

@param name [String] The interface name to return a resource hash for
from the node's running configuration.

@return [nil, Hash<Symbol, Object>] Returns the interface resource as a
hash. If the specified interface name is not found in the node's
configuration a nil object is returned. config = get\_block("^interface
{name}")

parse\_speed scans the provided configuration block and parses the speed
value. If the speed value is not found in the interface configuration
block provided, DEFAULT\_SPEED and DEFAULT\_FORCED are used. The
returned hash is intended to be merged into the interface resource hash.

@api private

@param config [String] The configuration block to parse.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_sflow scans the provided configuration block and parse the sflow
value. The sflow values true if sflow is enabled on the interface or
returns false if it is not enabled. The hash returned is intended to be
merged into the interface hash.

@api private

@param config [String] The configuration block to parse.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_flowcontrol\_send scans the provided configuration block and
parses the flowcontrol send value. If the interface flowcontrol value is
not configured, then this method will return the value of
DEFAULT\_ETH\_FLOWC\_TX. The hash returned is intended to be merged into
the interface resource hash.

@api private

@param config [String] The configuration block to parse.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_flowcontrol\_receive scans the provided configuration block and
parse the flowcontrol receive value. If the interface flowcontrol value
is not configured, then this method will return the value of
DEFAULT\_ETH\_FLOWC\_RX. The hash returned is intended to be merged into
the interface resource hash.

@api private

@param config [String] The configuration block to parse.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

create overrides the create method from the BaseInterface and raises an
exception because Ethernet interface creation is not supported.

@param \_name [String] The name of the interface.

@raise [NotImplementedError] Creation of physical Ethernet interfaces is
not supported.

delete overrides the delete method fro the BaseInterface instance and
raises an exception because Ethernet interface deletion is not
supported.

@param \_name [String] The name of the interface.

@raise [NotImplementedError] Deletion of physical Ethernet interfaces is
not supported.

set\_speed configures the interface speed and negotiation values on the
specified interface. If the enable option is false the speed setting is
configured using the no keyword. If the default options is set to true,
then the speed setting is configured using the default keyword. If both
options are specified, the default keyword takes precedence.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the speed setting to
in the nodes running configuration.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts forced [Boolean] Specifies if auto negotiation should be
enabled (true) or disabled (false).

@option opts default [Boolean] Configures the sflow value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["interface {name}"] cmds << enable ? "speed {forced} {value}" :
'no speed'

set\_sflow configures the administrative state of sflow on the
interface. Setting the enable keyword to true enables sflow on the
interface and setting enable to false disables sflow on the interface.
If the default keyword is set to true, then the sflow value is defaulted
using the default keyword. The default keyword takes precedence over the
enable keyword

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts enable [Boolean] Enables sflow if the value is true or
disables sflow on the interface if false. Default is true.

@option opts default [Boolean] Configures the sflow value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_flowcontrol configures the flowcontrol value either on or off for
the for the specified interface in the specified direction (either send
or receive). If the enable keyword is false then the configuration is
negated using the no keyword. If the default keyword is set to true,
then the state value is defaulted using the default keyword. The default
keyword takes precedence over the enable keyword

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param direction [String] Specifies the flowcontrol direction to
configure. Valid values include send and receive.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure the
flowcontrol setting for. Valid values include on or off.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the flowcontrol value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.
commands = command\_builder("flowcontrol {direction}", opts)

set\_flowcontrol\_send is a convenience function for configuring the
value of interface flowcontrol.

@see set\_flowcontrol

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure the
flowcontrol setting for. Valid values include on or off.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the flowcontrol value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_flowcontrol\_receive is a convenience function for configuring the
value of interface flowcontrol.

@see set\_flowcontrol

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure the
flowcontrol setting for. Valid values include on or off.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the flowcontrol value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

The PortchannelInterface class manages all port channel interfaces on an
EOS node.

get returns the specified port-channel interface configuration from the
nodes running configuration as a resource hash. The resource hash
returned extends the BaseInterface resource hash, sets the type value to
portchannel and adds the portchannel specific attributes

@example { type: 'portchannel' description: shutdown: [true, false]
members: array[] lacp\_mode: [active, passive, on] minimum\_links:
lacp\_timeout: lacp\_fallback: [static, individual, disabled] }

@see BaseInterface Interface get example

@param name [String] The name of the portchannel interface to return a
resource hash for. The name must be the full interface name of the
desired interface.

@return [nil, Hash<Symbol, Object>] Returns the interface resource as a
hash object. If the specified interface does not exist in the running
configuration, a nil object is returned. config = get\_block("^interface
{name}")

parse\_members scans the nodes running config and returns all of the
Ethernet members for the port-channel interface specified. If the
port-channel interface has no members configured, then this method will
assign an empty array as the value for members. The hash returned is
intended to be merged into the interface resource hash.

@api private

@param name [String] The name of the portchannel interface to extract
the members for.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
command = "show port-channel {grpid} all-ports"

parse\_lacp\_mode scans the member interfaces and returns the configured
lacp mode. The lacp mode value must be common across every member in the
port channel interface. If no members are configured, the value for
lacp\_mode will be set using DEFAULT\_LACP\_MODE. The hash returned is
intended to be merged into the interface resource hash

@api private

@param name [String] The name of the portchannel interface to extract
the members from in order to get the configured lacp\_mode.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.
config = get\_block("interface {members.first}")

parse\_minimum\_links scans the port-channel configuration and returns
the value for port-channel minimum-links. If the value is not found in
the interface configuration, then DEFAULT\_MIN\_LINKS value is used. The
hash returned is intended to be merged into the interface resource hash.

@api private

@param config [String] The interface configuration block to extract the
minimum links value from.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_lacp\_fallback scans the interface config block and returns the
configured value of the lacp fallback attribute. If the value is not
configured, then the method will return the value of
DEFAULT\_LACP\_FALLBACK. The hash returned is intended to be merged into
the interface resource hash.

@api private

@param config [String] The interface configuration block to extract the
lacp fallback value from.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_lacp\_timeout scans the interface config block and returns the
value of the lacp fallback timeout value. The value is expected to be
found in the interface configuration block. The hash returned is
intended to be merged into the interface resource hash.

@api private

@param config [String] The interface configuration block to extract the
lacp timeout value from.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

set\_minimum\_links configures the minimum physical links up required to
consider the logical portchannel interface operationally up. If the
enable keyword is false then the minimum-links is configured using the
no keyword argument. If the default keyword argument is provided and set
to true, the minimum-links value is defaulted using the default keyword.
The default keyword takes precedence over the enable keyword argument if
both are provided.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String, Integer] Specifies the value to configure
the minimum-links to in the configuration. Valid values are in the range
of 1 to 16.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the minimum links value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_members configures the set of physical interfaces that comprise the
logical port-channel interface. The members value passed should be an
array of physical interface names that comprise the port-channel
interface. This method will add and remove individual members as
required to sync the provided members array.

@see add\_member Adds member links to the port-channel interface.

@see remove\_member Removes member links from the port-channel
interface.

@param name [String] The name of the port-channel interface to apply the
members to. If the port-channel interface does not already exist it will
be created.

@param members [Array] The array of physical interface members to add to
the port-channel logical interface.

@param mode [str] The LACP mode to configure the member interfaces to.
Valid values are 'on, 'passive', 'active'. When there are existing
channel-group members and their lacp mode differs from this attribute,
all of those members will be removed and then re-added using the
specified lacp mode. If this attribute is omitted, the existing lacp
mode will be used for new member additions.

@return [Boolean] Returns true if the command completed successfully.
remove members from the current port-channel interface. cmds <<
"interface {intf}" cmds << "no channel-group {grpid}" add new member
interfaces to the port-channel. cmds << "interface {intf}" cmds <<
"channel-group {grpid} mode {lacp\_mode}"

add\_member adds the interface specified in member to the port-channel
interface specified by name in the nodes running-configuration. If the
port-channel interface does not already exist, it will be created.

@since eos\_version 4.13.7M

@param name [String] The name of the port-channel interface to apply the
configuration to.

@param member [String] The name of the physical Ethernet interface to
add to the logical port-channel interface.

@return [Boolean] Returns true if the command completed successfully.
configure\_interface(member, "channel-group {grpid} mode {lacp}")

remove\_member removes the interface specified in member from the
port-channel interface specified by name in the nodes
running-configuration.

@since eos\_version 4.13.7M

@param name [String] The name of the port-channel interface to apply the
configuration to.

@param member [String] The name of the physical Ethernet interface to
remove from the logical port-channel interface.

@return [Boolean] Returns true if the command completed successfully.
configure\_interface(member, "no channel-group {grpid}")

set\_lacp\_mode configures the lacp mode on the port-channel interface
by configuring the lacp mode value for each member interface. This
method will find all member interfaces for a port-channel and
reconfigure them using the mode argument.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param mode [String] The lacp mode to configure on the member interfaces
for the port-channel. Valid values include active, passive or on.

@return [Boolean] Returns true if the command completed successfully.
remove\_commands << "interface {member}" remove\_commands << "no
channel-group {grpid}" add\_commands << "interface {member}"
add\_commands << "channel-group {grpid} mode {mode}"

set\_lacp\_fallback configures the lacp fallback mode for the
port-channel interface. If the enable keyword is false, lacp fallback is
configured using the no keyword argument. If the default option is
specified and set to true, the lacp fallback value is configured using
the default keyword. The default keyword takes precedence over the
enable keyword if both options are provided.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure for the
port-channel lacp fallback. Valid values are individual and static.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the lacp fallback value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_lacp\_timeout configures the lacp fallback timeout for the
port-channel interface. If the enable keyword is false, lacp fallback
timeout is configured using the no keyword argument. If the default
option is specified and set to true, the lacp fallback timeout value is
configured using the default keyword. The default keyword takes
precedence over the enable keyword if both options are provided.

@since eos\_version 4.13.7M

@param name [String] The interface name to apply the configuration
values to. The name must be the full interface identifier.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure for the
port-channel lacp fallback timeout.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the lacp fallback timeout
value on the interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

The VxlanInterface class manages all Vxlan interfaces on an EOS node.

Returns the Vxlan interface configuration as a Ruby hash of key/value
pairs from the nodes running configuration. This method extends the
BaseInterface get method and adds the Vxlan specific attributes to the
hash.

@example { name: , type: , description: , shutdown: , source\_interface:
, multicast\_group: , udp\_port: , flood\_list: , vlans: }

@param name [String] The interface name to return from the nodes
configuration. This optional parameter defaults to Vxlan1.

@return [nil, Hash<String, String>] Returns the interface configuration
as a Ruby hash object. If the provided interface name is not found then
this method will return nil. config = get\_block("interface {name}")

parse\_source\_interface scans the interface config block and returns
the value of the vxlan source-interface. If the source-interface is not
configured then the value of DEFAULT\_SRC\_INTF is used. The hash
returned is intended to be merged into the interface resource hash

@api private

@param config [String] The interface configuration block to extract the
vxlan source-interface value from.

@return [Hash<Symbol, Object>]

parse\_multicast\_group scans the interface config block and returns the
value of the vxlan multicast-group. If the multicast-group is not
configured then the value of DEFAULT\_MCAST\_GRP is used. The hash
returned is intended to be merged into the interface resource hash.

@api private

@param config [String] The interface configuration block to extract the
vxlan multicast-group value from.

@return [Hash<Symbol, Object>]

parse\_udp\_port scans the interface config block and returns the value
of the vxlan udp-port setting. The vxlan udp-port value is expected to
always be present in the configuration. The returned value is intended
to be merged into the interface resource Hash.

@api private

@param config [String] The interface configuration block to parse the
vxlan udp-port value from.

@return [Hash<Symbol, Object>]

parse\_flood\_list scans the interface config block and returns the list
of configured VTEPs that comprise the flood list. If there are no flood
list values configured, the value will return DEFAULT\_FLOOD\_LIST. The
returned value is intended to be merged into the interface resource
Hash.

@api private

@param config [String] The interface configuration block to parse the
vxlan flood list values from.

@return [Hash<Symbol, Object>]

parse\_vlans scans the interface config block and returns the set of
configured vlan to vni mappings. If there are no vlans configured, the
value will return an empty Hash.

@api private

@param config [String] The interface configuration block to parse the
vxlan flood list values from.

@return [Hash<Symbol, Object>]

Configures the vxlan source-interface to the specified value. This
parameter should be the interface identifier of the interface to act as
the source for all Vxlan traffic.

@param name [String] The name of the interface to apply the
configuration values to.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Configures the vxlan source-interface to the
specified value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Specifies whether or not the
multicast-group command is configured as default. The value of this
option has a higher precedence than :enable.

@return [Boolean] Returns true if the commands complete successfully.

Configures the vxlan multicast-group flood address to the specified
value. The value should be a valid multicast address.

@param name [String] The name of the interface to apply the
configuration values to.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Configures the multicast-group flood address
to the specified value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Specifies whether or not the
multicast-group command is configured as default. The value of this
option has a higher precedence than :value.

@return [Boolean] Returns true if the commands complete successfully.

set\_udp\_port configures the Vxlan udp-port value in EOS for the
specified interface name. If the enable keyword is false then the no
keyword is used to configure the value. If the default option is
provided and set to true, then the default keyword is used. If both
options are provided, the default keyword will take precedence.

@since eos\_version 4.13.7M

@param name [String] The name of the vxlan interface to configure.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] Specifies the value to configure the
udp-port setting to. Valid values are in the range of 1024 to 65535.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the udp-port value on the
interface using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

add\_vtep adds a new VTEP endpoint to the global flood list for the
specified interface. If the VTEP endpoint is already configured, this
method will still return successfully.

@since eos\_version 4.13.7M

@param name [String] The name of the interface to configure.

@param vtep [String] The IP address of the remote VTEP endpoint.

@return [Boolean] Returns true if the commands completed successfully.
configure\_interface(name, "vxlan flood vtep add {vtep}")

remove\_vtep deletes a VTEP endpoint from the global flood list for the
specified interface. If the VTEP endpoint specified is not configured,
this method will still return successfully.

@since eos\_version 4.13.7M

@param name [String] The name of the interface to configure.

@param vtep [String] The IP address of the remote VTEP endpoint.

@return [Boolean] Returns true if the commands completed successfully.
configure\_interface(name, "vxlan flood vtep remove {vtep}")

update\_vlan creates a new vlan to vni mapping for the specified
interface in the nodes current configuration.

@since eos\_verson 4.13.7M

@param name [String] The name of the interface to configure.

@param vlan [Fixnum] The VLAN ID to configure.

@param vni [Fixnum] The VNI value to map the VLAN into.

@return [Boolean] Returns true if the command completed successfully.
configure\_interface(name, "vxlan vlan {vlan} vni {vni}")

remove\_vlan deletes a previously configured VLAN to VNI mapping on the
specified interface.

@since eos\_version 4.13.7M

@param name [String] the name of the interface to configure.

@param vlan [Fixnum] The VLAN ID to remove from the configuration. If
the VLAN ID does not exist, this method will still return successfully.

@return [Boolean] Returns true if the command completed successfully.
configure\_interface(name, "no vxlan vlan {vlan} vni")

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Ipinterface class provides an instance for managing logical IP
interfaces configured using eAPI.

get returns a resource hash that represents the configuration of the IP
interface from the nodes running configuration.

@example { address: , mtu: , helper\_addresses: array }

@param name [String] The full interface identifier of the interface to
return the resource configuration hash for. The name must be the full
name (Ethernet, not Et).

@return [nil, Hash<Symbol, Object>] Returns the ip interface
configuration as a hash. If the provided interface name is not a
configured ip address, nil is returned. config = get\_block("interface
{name}")

getall returns a hash object that represents all ip interfaces
configured on the node from the current running configuration.

@example { : { address: , mtu: , helper\_addresses: array }, : {
address: , mtu: , helper\_addresses: array }, ... }

@see get Ipaddress resource example

@return [Hash<Symbol, Object>] Returns a hash object that represents all
of the configured IP addresses found. If no IP addresses are configured,
then an empty hash is returned.

parse\_address scans the provided configuration block and extracts the
interface address, if configured, and returns it. If there is no IP
address configured, then this method will return the DEFAULT\_ADDRESS.
The return value is intended to be merged into the ipaddress resource
hash.

@api private

@param config [String] The IP interface configuration block returned
from the node's running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_mtu scans the provided configuration block and extracts the IP
interface MTU value. The MTU value is expected to always be present in
the configuration blcok. The return value is intended to be merged into
the ipaddress resource hash.

@api private

@param config [String] The IP interface configuration block returned
from the node's running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_helper\_addresses scans the provided configuration block and
extracts any configured IP helper address values. The interface could be
configured with one or more helper addresses. If no helper addresses are
configured, then an empty array is set in the return hash. The return
value is intended to be merged into the ipaddress resource hash.

@api private

@param config [String] The IP interface configuration block returned
from the node's running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

create will create a new IP interface on the node. If the ip interface
already exists in the configuration, this method will still return
successful. This method will cause an existing layer 2 interface
(switchport) to be deleted if it exists in the node's configuration.

@since eos\_version 4.13.7M

commands interface no switchport

@param name [String] The full interface name of the port to create the
logical interface on. The name must be the full interface identifier.

@return [Boolean] Returns true if the commands complete successfully.
configure(["interface {name}", 'no switchport'])

delete will delete an existing IP interface in the node's current
configuration. If the IP interface does not exist on the specified
interface, this method will still return success. This command will
default the interface back to being a switchport.

@since eos\_version 4.13.7M

commands interface no ip address switchport

@param name [String] The full interface name of the port to delete the
logical interface from. The name must be the full interface name

@return [Boolean] Returns true if the commands complete successfully.
configure(["interface {name}", 'no ip address', 'switchport'])

set\_address configures a logical IP interface with an address. The
address value must be in the form of A.B.C.D/E. If the enable keyword is
false, then the interface address is negated using the config no
keyword. If the default option is set to true, then the ip address value
is defaulted using the default keyword. The default keyword has
precedence over the enable keyword if both options are specified.

@since eos\_version 4.13.7M

commands interface ip address no ip address default ip address

@param name [String] The name of the interface to configure the address
in the node. The name must be the full interface name.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the address to for
the specified interface name. The value must be in the form of
A.B.C.D/E.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the ip address value using the
default keyword.

@return [Boolean] Returns True if the command completed successfully.

set\_mtu configures the IP mtu value of the ip interface in the nodes
configuration. If the enable option is false, then the ip mtu value is
configured using the no keyword. If the default keyword option is
provided and set to true then the ip mtu value is configured using the
default keyword. The default keyword has precedence over the enable
keyword if both options are specified.

@since eos\_version 4.13.7M

commands interface mtu no mtu default mtu

@param name [String] The name of the interface to configure the address
in the node. The name must be the full interface name.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the IP MTU to in the
nodes configuration. Valid values are in the range of 68 to 9214 bytes.
The default is 1500 bytes.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the ip mtu value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_helper\_addresses configures the list of helper addresses on the ip
interface. An IP interface can have one or more helper addresses
configured. If no value is provided, the helper address configuration is
set using the no keyword. If the default option is specified and set to
true, then the helper address values are defaulted using the default
keyword.

@since eos\_version 4.13.7M

commands interface ip helper-address no ip helper-address default ip
helper-address

@param name [String] The name of the interface to configure the address
in the node. The name must be the full interface name.

@param opts [Hash] Optional keyword arguments.

@option opts value [Array] The list of IP addresses to configure as
helper address on the interface. The helper addresses must be valid
addresses in the main interface's subnet.

@option opts default [Boolean] Configure the ip helper address values
using the default keyword.

value.each { \|addr\| cmds << "ip helper-address {addr}" } if enable

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Logging class manages logging settings on an EOS node.

get returns the current logging configuration hash extracted from the
nodes running configuration.

@example { enable: [true, false], hosts: array }

@return [Hash<Symbol, Object>] Returns the logging resource as a hash
object from the nodes current configuration.

parse\_enable scans the nodes current running configuration and extracts
the current enabled state of the logging facility. The logging enable
command is expected to always be in the node's configuration. This
methods return value is intended to be merged into the logging resource
hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_hosts scans the nodes current running configuration and extracts
the configured logging host destinations if any are configured. If no
logging hosts are configured, then the value for hosts will be an empty
array. The return value is intended to be merged into the logging
resource hash

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

set\_enable configures the global logging instance on the node as either
enabled or disabled. If the enable keyword is set to true then logging
is globally enabled and if set to false, it is globally disabled. If the
default keyword is specified and set to true, then the configuration is
defaulted using the default keyword. The default keyword option takes
precedence over the enable keyword if both options are specified.

@since eos\_version 4.13.7M

commands logging on no logging on default logging on

@param opts [Hash] Optional keyword arguments

@option opts enable [Boolean] Enables logging globally if value is true
or disabled logging globally if value is false.

@option opts default [Boolean] Configure the ip address value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

add\_host configures a new logging destination host address or hostname
to the list of logging destinations. If the host is already configured
in the list of destinations, this method will return successfully.

@since eos\_version 4.13.7M

commands logging host

@param name [String] The host name or ip address of the destination node
to send logging information to.

@return [Boolean] Returns true if the command completed successfully.
configure "logging host {name}"

remove\_host deletes a logging destination host name or address form the
list of logging destinations. If the host is not in the list of
configured hosts, this method will still return successfully.

@since eos\_version 4.13.7M

commands no logging host

@param name [String] The host name or ip address of the destination host
to remove from the nodes current configuration.

@return [Boolean] Returns true if the commands completed successfully.
configure "no logging host {name}"

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Mlag class provides a configuration instance for working with the
global MLAG configuration of the node.

get scans the current nodes configuration and returns the values as a
Hash describing the current state.

@example { global: { domain\_id: , local\_interface: , peer\_address: ,
peer\_link: , shutdown: }, interfaces: { : { mlag\_id: }, : { mlag\_id:
}, ... } }

@see parse\_interfaces

@return [nil, Hash<Symbol, Object] returns the nodes current running
configuration as a Hash. If mlag is not configured on the node this
method will return nil.

parse\_domain\_id scans the current nodes running configuration and
extracts the mlag domain-id value. If the mlag domain-id has not been
configured, then this method will return DEFAULT\_DOMAIN\_ID. The return
value is intended to be merged into the resource hash.

@api private

@param config [String] The mlag configuration block retrieved from the
nodes current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_local\_interface scans the current nodes running configuration
and extracts the mlag local-interface value. If the mlag local-interface
has not been configured, this method will return DEFAULT\_LOCAL\_INTF.
The return value is intended to be merged into the resource hash.

@api private

@param config [String] The mlag configuration block retrieved from the
nodes current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_peer\_address scans the current nodes running configuration and
extracts the mlag peer-address value. If the mlag peer-address has not
been configured, this method will return DEFAULT\_PEER\_ADDR. The return
value is intended to be merged into the resource hash.

@api private

@param config [String] The mlag configuration block retrieved from the
nodes current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_peer\_link scans the current nodes running configuration and
extracts the mlag peer-link value. If the mlag peer-link hash not been
configure, this method will return DEFAULT\_PEER\_LINK. The return value
is intended to be merged into the resource hash.

@api private

@param config [String] The mlag configuration block retrieved from the
nodes current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute

parse\_shutdown scans the current nodes mlag configuration and extracts
the mlag shutdown value. The mlag configuration should always return the
value of shutdown from the configuration block. The return value is
intended to be merged into the resource hash.

@api private

@param config [String] The mlag configuration block retrieved from the
nodes current running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_interfaces scans the global configuration and returns all of the
configured MLAG interfaces. Each interface returns the configured MLAG
identifier for establishing a MLAG peer. The return value is intended to
be merged into the resource Hash.

The resource Hash attribute returned contains: \* mlag\_id: (Fixnum) The
configured MLAG identifier.

@api private

@return [Hash<Symbol, Object>] Returns the resource Hash attribute.
config = get\_block("^interface {name}")

set\_domain\_id configures the mlag domain-id value in the current nodes
running configuration. If the enable keyword is false, the the domain-id
is configured with the no keyword. If the default keyword is provided,
the configuration is defaulted using the default keyword. The default
keyword takes precedence over the enable keyword if both options are
specified.

@since eos\_version 4.13.7M

commands mlag configuration domain-id no domain-id default domain-id

@param opts [Hash] Optional keyword arguments

@option opts value [String] The value to configure the mlag domain-id
to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the domain-id value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_local\_interface configures the mlag local-interface value in the
current nodes running configuration. If the enable keyword is false, the
local-interface is configured with the no keyword. If the default
keyword is provided, the configuration is defaulted using the default
keyword. The default keyword takes precedence over the enable keyword if
both options are specified

@since eos\_version 4.13.7M

commands mlag configuration local-interface no local-interface default
local-interface

@param opts [Hash] Optional keyword arguments

@option opts value [String] The value to configure the mlag
local-interface to. The local-interface accepts full interface
identifiers and expects a Vlan interface

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the local-interface value using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_peer\_link configures the mlag peer-link value in the current nodes
running configuration. If enable keyword is false, then the peer-link is
configured with the no keyword. If the default keyword is provided, the
configuration is defaulted using the default keyword. The default
keyword takes precedence over the enable keyword if both options are
specified.

@since eos\_version 4.13.7M

commands mlag configuration peer-link no peer-link default peer-link

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the mlag peer-link
to. The peer-link accepts full interface identifiers and expects an
Ethernet or Port-Channel interface.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer-link using the default
keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_peer\_address configures the mlag peer-address value in the current
nodes running configuration. If the enable keyword is false, then the
peer-address is configured with the no keyword. If the default keyword
is provided, the configuration is defaulted using the default keyword.
The default keyword takes precedence over the enable keyword if both
options are specified

@since eos\_version 4.13.7M

commands mlag configuration peer-address no peer-address default
peer-address

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the mlag peer-address
to. The peer-address accepts an IP address in the form of A.B.C.D/E.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the peer-address using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_shutdown configures the administrative state of the mlag process on
the current node. If the enable keyword is true, then mlag is enabled
and if the enable keyword is false, then mlag is disabled. If the
default keyword is provided, the configuration is defaulted using the
default keyword. The default keyword takes precedence over the enable
keyword if both options are specified

@since eos\_version 4.13.7M

commands mlag configuration shutdown no shutdown default shutdown

@param opts [Hash] Optional keyword arguments.

@option opts enable [Boolean] True if the interface should be
administratively enabled or false if the interface should be
administratively disabled.

@option opts default [Boolean] Configure the shutdown value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.
Shutdown semantics are opposite of enable semantics so invert enable

set\_mlag\_id configures the mlag id on the interface in the nodes
current running configuration. If the enable keyword is false, then the
interface mlag id is configured using the no keyword. If the default
keyword is provided and set to true, the interface mlag id is configured
using the default keyword. The default keyword takes precedence over the
enable keyword if both options are specified

@since eos\_version 4.13.7M

commands interface mlag no mlag default mlag

@param name [String] The full interface identifier of the interface to
configure th mlag id for.

@param opts [Hash] Optional keyword arguments.

@option opts value [String, Integer] The value to configure the
interface mlag to. The mlag id should be in the valid range of 1 to
2000.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the mlag value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Ntp class provides an instance for working with the nodes NTP
configuration.

get returns the nodes current ntp configure as a resource hash.

@example { source\_interface: , servers: { prefer: [true, false] } }

@return [nil, Hash<Symbol, Object>] Returns the ntp resource as a Hash.

parse\_source\_interface scans the nodes configurations and parses the
ntp source interface if configured. If the source interface is not
configured, this method will return DEFAULT\_SRC\_INTF as the value. The
return hash is intended to be merged into the resource hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_servers scans the nodes configuration and parses the configured
ntp server host names and/or addresses. This method will also return the
value of prefer. If no servers are configured, the value will be set to
an empty array. The return hash is intended to be merged into the
resource hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

set\_source\_interface configures the ntp source value in the nodes
running configuration. If the enable keyword is false, then the ntp
source is configured with the no keyword argument. If the default
keyword argument is provided and set to true, the value is configured
used the default keyword. The default keyword takes precedence over the
enable keyword if both options are specified.

@since eos\_version 4.13.7M

commands ntp source no ntp source default ntp source

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the ntp source in the
nodes configuration.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the ntp source value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

add\_server configures a new ntp server destination hostname or ip
address to the list of ntp destinations. The optional prefer argument
configures the server as a preferred (true) or not (false) ntp
destination.

@param server [String] The IP address or FQDN of the NTP server to be
removed from the configuration.

@param prefer [Boolean] Appends the prefer keyword argument to the
command if this value is true.

@return [Boolean] Returns true if the command completed successfully.
cmd = "ntp server {server}"

remove\_server deletes the provided server destination from the list of
ntp server destinations. If the ntp server does not exist in the list of
servers, this method will return successful

@param server [String] The IP address or FQDN of the NTP server to be
removed from the configuration.

@return [Boolean] Returns true if the command completed successfully.
configure("no ntp server {server}")

set\_prefer will set the prefer keyword for the specified ntp server. If
the server does not already exist in the configuration, it will be added
and the prefer keyword will be set.

@since eos\_version 4.13.7M

commands ntp server prefer no ntp server prefer

@param srv [String] The IP address or hostname of the ntp server to
configure with the prefer value.

@param value [Boolean] The value to configure for prefer. If true the
prefer value is configured for the server. If false, then the prefer
value is removed.

@return [Boolean] Returns true if the commands completed successfully.
cmds = "ntp server {srv} prefer" cmds = ["no ntp server {srv} prefer",
"ntp server {srv}"]

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Ospf class is a global class that provides an instance for working
with the node's OSPF configuration.

Returns the global OSPF configuration from the node.

rubocop:disable Metrics/MethodLength

@example { router\_id: areas: { : array }, redistribute: {} }

@param inst [String] The ospf instance name.

@return [Hash] A Ruby hash object that provides the OSPF settings as key
/ value pairs. config = get\_block("router ospf {inst}")

Returns the OSPF configuration from the node as a Ruby hash.

@example { : { router\_id: , areas: {}, redistribute: {} }, interfaces:
{} }

@return [Hash] A Ruby hash object that provides the OSPF settings as key
/ value pairs.

create will create a router ospf with the specified pid.

@param pid [String] The router ospf to create.

@return [Boolean] Returns true if the command completed successfully.
configure "router ospf {pid}"

delete will remove the specified router ospf.

@param pid [String] The router ospf to remove.

@return [Boolean] Returns true if the command completed successfully.
configure "no router ospf {pid}"

set\_router\_id sets router ospf router-id with pid and options.

@param pid [String] The router ospf name.

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the router-id to default.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["router ospf {pid}", cmd]

add\_network adds network settings for router ospf and network area.

@param pid [String] The pid for router ospf.

@param net [String] The network name.

@param area [String] The network area name.

@return [Boolean] Returns true if the command completed successfully.
configure ["router ospf {pid}", "network {net} area {area}"]

remove\_network removes network settings for router ospf and network
area.

@param pid [String] The pid for router ospf.

@param net [String] The network name.

@param area [String] The network area name.

@return [Boolean] Returns true if the command completed successfully.
configure ["router ospf {pid}", "no network {net} area {area}"]

set\_redistribute sets router ospf router-id with pid and options.

@param pid [String] The router ospf name.

@param proto [String] The redistribute value.

@param opts [hash] Optional keyword arguments.

@option opts routemap [String] The route-map value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the router-id to default.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["router ospf {pid}", "redistribute {proto}"] cmds[1] << "
route-map {routemap}" if routemap

The OspfInterfaces class is a global class that provides an instance for
working with the node's OSPF interface configuration.

Returns a single MLAG interface configuration.

Example { network\_type: }

@param name [String] The interface name to return the configuration
values for. This must be the full interface identifier.

@return [nil, Hash<String, String>] A Ruby hash that represents the MLAG
interface configuration. A nil object is returned if the specified
interface is not configured config = get\_block("interface {name}")

Returns the collection of MLAG interfaces as a hash index by the
interface name.

Example { : { network\_type: }, : { network\_type: }, ... }

@return [nil, Hash<String, String>] A Ruby hash that represents the MLAG
interface configuration. A nil object is returned if no interfaces are
configured.

set\_network\_type sets network type with options.

@param name [String] The name of the interface.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The point-to-point value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the ip ospf network to default.

@return [Boolean] Returns true if the command completed successfully.

Copyright (c) 2014, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Prefixlists class provides a configuration instance for working with
static routes in EOS.

Returns the static routes configured on the node.

@example { : { next\_hop: , name: } }

@param name [String] The name of the prefix-list to return.

@return [Hash The method will return all of the configured static routes
on the node as a Ruby hash object. If there are no static routes
configured, this method will return an empty hash. config =
get\_block("ip prefix-list {name}")

Returns the static routes configured on the node.

@example { : { next\_hop: , name: } }

@return [Hash The method will return all of the configured static routes
on the node as a Ruby hash object. If there are no static routes
configured, this method will return an empty hash.

create will create a new ip prefix-list with designated name.

@param name [String] The name of the ip prefix-list.

@return [Boolean] Returns true if the command completed successfully.
configure "ip prefix-list {name}"

add\_rule will create an ip prefix-list with the designated name, seqno,
action and prefix.

@param name [String] The name of the ip prefix-list.

@param seq [String] The seq value.

@param action [String] The action value.

@param prefix [String] The prefix value.

@return [Boolean] Returns true if the command completed successfully.
cmd = "ip prefix-list {name}" cmd << " seq {seq}" if seq cmd << "
{action} {prefix}"

delete will remove the designated prefix-list.

@param name [String] The name of the ip prefix-list.

@param seq [String] The seq value.

@return [Boolean] Returns true if the command completed successfully.
cmd = "no ip prefix-list {name}" cmd << " seq {seq}" if seq

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

Radius provides instance methods to retrieve and set radius
configuration values. Regular expression to extract a radius server's
attributes from the running-configuration text. The explicit [ ] spaces
enable line wrapping and indentation with the /x flag.

get Returns an Array with a single resource Hash describing the current
state of the global radius configuration on the target device. This
method is intended to be used by a provider's instances class method.

@example { key: , key\_format: , timeout: , retransmit: , servers: }

@return [Array<Hash>] Single element Array of resource hashes.

parse\_time scans the nodes current configuration and parse the
radius-server timeout value. The timeout value is expected to always be
present in the config.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_retransmit scans the cnodes current configuration and parses the
radius-server retransmit value. The retransmit value is expected to
always be present in the config.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_key scans the current nodes running configuration and parse the
global radius-server key and format value. If the key is not configured
this method will return DEFAULT\_KEY and DEFAULT\_KEY\_FORMAT for the
resource hash values.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_servers returns an Array of radius server resource hashes. Each
hash describes the current state of the radius server and is intended to
be merged into the radius resource hash.

The resource hash returned contains the following information: \*
hostname: hostname or ip address \* vrf: (String) vrf name \* key:
(String) the key either in plain text or hashed format \* key\_format:
(Fixnum) e.g. 0 or 7 \* timeout: (Fixnum) seconds before the timeout
period ends \* retransmit: (Integer), e.g. 3, attempts after first
timeout expiry. \* group: (String) Server group associated with this
server. \* acct\_port: (Fixnum) Port number to use for accounting. \*
accounting\_only: (Boolean) Enable this server for accounting only. \*
auth\_port: (Fixnum) Port number to use for authentication

@api private

@return [Array<Hash<Symbol,Object>>] Array of resource hashes.

set\_global\_key configures the global radius-server key. If the enable
option is false, radius-server key is configured using the no keyword.
If the default option is specified, radius-server key is configured
using the default keyword. If both options are specified, the default
keyword option takes precedence.

@since eos\_version 4.13.7M

commands radius-server key no radius-server key default radius-server
key

@option value [String] The value to configure the radius-server key to
in the nodes running configuration.

@option key\_format [Fixnum] The format of the key to be passed to the
nodes running configuration. Valid values are 0 (clear text) or 7
(encrypted). The default value is 0 if format is not provided.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option default [Boolean] Configures the radius-server key using the
default keyword argument.

@return [Boolean] Returns true if the commands complete successfully.
cmds = "radius-server key {key\_format} {value}"

set\_global\_timeout configures the radius-server timeout value. If the
enable option is false, then radius-server timeout is configured using
the no keyword. If the default option is specified, radius-server
timeout is configured using the default keyword. If both options are
specified then the default keyword takes precedence.

@since eos\_version 4.13.7M

commands radius-server timeout no radius-server timeout default
radius-server timeout

@option value [String, Fixnum] The value to set the global radius-server
timeout value to. This value should be in the range of 1 to 1000.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option default [Boolean] Configures the radius-server timeout value
using the default keyword.

@return [Boolean] Returns true if the commands complete successfully.

set\_global\_retransmit configures the global radius-server retransmit
value. If the enable option is false, then the radius-server retransmit
value is configured using the no keyword. If the default option is
specified, the radius-server retransmit value is configured using the
default keyword. If both options are specified then the default keyword
takes precedence.

@since eos\_version 4.13.7M

commands radius-server retransmit no radius-server retransmit default
radius-server retransmit

@option value [String, Fixnum] The value to set the global radius-server
retransmit value to. This value should be in the range of 1 to 100

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option default [Boolean] Configures the radius-server retransmit value
using the default keyword.

@return [Boolean] Returns true if the commands complete successfully.

update\_server configures a radius server resource on the target device.
This API method maps to the ``radius server host`` command, e.g.
``radius-server host 10.11.12.13 auth-port 1024 acct-port 2048 timeout  30 retransmit 5 key 7 011204070A5955``.

@api public

@param opts [Hash] The configuration options.

@option opts key\_format [Integer] The key format value.

@option opts hostname [String] The host value.

@option opts vrf [String] The vrf value.

@option opts auth\_port [String] The auth-port value.

@option opts acct\_port [String] The acct-port value.

@option opts timeout [String] The timeout value.

@option opts retransmit [String] The retransmit value.

@option opts key [String] The key value.

@return [Boolean] Returns true if there are no errors. beware: order of
cli keyword options counts cmd = "radius-server host {opts[:hostname]}"
cmd << " vrf {opts[:vrf]}" if opts[:vrf] cmd << " auth-port
{opts[:auth\_port]}" if opts[:auth\_port] cmd << " acct-port
{opts[:acct\_port]}" if opts[:acct\_port] cmd << " timeout
{opts[:timeout]}" if opts[:timeout] cmd << " retransmit
{opts[:retransmit]}" if opts[:retransmit] cmd << " key {key\_format}
{opts[:key]}" if opts[:key]

remove\_server removes the SNMP server identified by the hostname,
auth\_port, and acct\_port attributes.

@api public

@param opts [Hash] The configuration options.

@option opts hostname [String] The host value.

@option opts vrf [String] The vrf value.

@option opts auth\_port [String] The auth-port value.

@option opts acct\_port [String] The acct-port value.

@return [Boolean] Returns true if there are no errors. cmd = "no
radius-server host {opts[:hostname]}" cmd << " vrf {opts[:vrf]}" if
opts[:vrf] cmd << " auth-port {opts[:auth\_port]}" if opts[:auth\_port]
cmd << " acct-port {opts[:acct\_port]}" if opts[:acct\_port]

Copyright (c) 2014, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Routemaps class manages routemaps. A route map is a list of rules
that control the redistribution of IP routes into a protocol domain on
the basis of such criteria as route metrics, access control lists, next
hop addresses, and route tags.

rubocop:disable Metrics/ClassLength

get returns a hash of routemap configurations for the given name.

@example { : { : { match: , set: , continue: , description: }, : {
match: , set: , continue: , description: } }, : { : { match: , set: ,
continue: , description: }, : { match: , set: , continue: , description:
} } }

@param name [String] The routemap name to return a resource for from the
nodes configuration.

@return [nil, Hash<Symbol, Object>] Returns the routemap resource as a
Hash. If the specified name is not found in the nodes current
configuration a nil object is returned.

getall returns a collection of routemap resource hashes from the nodes
running configuration. The routemap resource collection hash is keyed by
the unique routemap name.

@example { : { : { : { match: , set: , continue: , description: }, : {
match: , set: , continue: , description: } }, : { : { match: , set: ,
continue: , description: }, : { match: , set: , continue: , description:
} } }, : { : { : { match: , set: , continue: , description: }, : {
match: , set: , continue: , description: } }, : { : { match: , set: ,
continue: , description: }, : { match: , set: , continue: , description:
} } } }

@return [nil, Hash<Symbol, Object>] Returns a hash that represents the
entire routemap collection from the nodes running configuration. If
there are no routemap names configured, this method will return nil.

parse entries is a private method to get the routemap rules.

@api private

@param name [String] The routemap name.

@return [nil, Hash<Symbol, Object>] Returns a hash that represents the
rules for routemaps from the nodes running configuration. If there are
no routemaps configured, this method will return nil. entries =
config.scan(/^route-map:raw-latex:`\s{name}`:raw-latex:`\s`.+$/)

parse rule is a private method to parse a rule.

@api private

@param rules [Hash] Rules configuration options.

@option rules match [Array] The match options.

@option rules set [Array] The set options.

@option rules continue [String] The continue value.

@option rules description [String] The description value.

@return [Hash<Symbol, Object>] Returns a hash that represents the rules
for routemaps from the nodes running configuration. If there are no
routemaps configured, this method will return an empty hash.

name\_commands is utilized to initially prepare the routemap.

@param name [String] The routemap name.

@param action [String] The action value.

@param seqno [String] The seqno value.

@param opts [Hash] The configuration options.

@option opts default [Boolean] The default value.

@option opts enable [Boolean] The enable value.

@return [Array] Returns the prepared eos command. cmd = "default
route-map {name}" cmd = "no route-map {name}" cmd = "route-map {name}"
cmd << " {action}" cmd << " {seqno}"

create will create a new routemap with the specified name.

rubocop:disable Metrics/MethodLength

commands route-map action seqno description match set continue

@param name [String] The name of the routemap to create.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number value.

@param opts [hash] Optional keyword arguments.

@option opts default [Boolean] Set routemap to default.

@option opts description [String] A description for the routemap.

@option opts match [Array] routemap match rule.

@option opts set [String] Sets route attribute.

@option opts continue [String] The routemap sequence number to continue
on.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the routemap to default.

@return [Boolean] Returns true if the command completed successfully.
cmds << "description {opts[:description]}" cmds << "continue
{opts[:continue]}" cmds << "match {options}" cmds << "set {options}"

remove\_match\_statemements removes all match rules for the specified
routemap

@param name [String] The routemap name.

@param action [String] The action value.

@param seqno [String] The seqno value.

@param cmds [Array] Array of eos commands.

@return [Boolean] Returns true if the command completed successfully.
cmds << "no match {options}"

remove\_set\_statemements removes all set rules for the specified
routemap

@param name [String] The routemap name.

@param action [String] The action value.

@param seqno [String] The seqno value.

@param cmds [Array] Array of eos commands.

@return [Boolean] Returns true if the command completed successfully.
cmds << "no set {options}"

delete will delete an existing routemap name from the nodes current
running configuration. If the delete method is called and the routemap
name does not exist, this method will succeed.

commands no route-map

@param name [String] The routemap name to delete from the node.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@return [Boolean] Returns true if the command completed successfully.
configure(["no route-map {name} {action} {seqno}"])

This method will attempt to default the routemap from the nodes
operational config. Since routemaps do not exist by default, the default
action is essentially a negation and the result will be the removal of
the routemap clause. If the routemap does not exist then this method
will not perform any changes but still return True.

commands no route-map

@param name [String] The routemap name to set to default.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@return [Boolean] Returns true if the command completed successfully.
configure(["default route-map {name} {action} {seqno}"])

set\_match\_statements will set the match values for a specified
routemap. If the specified routemap does not exist, it will be created.

commands route-map action seqno match

@param name [String] The name of the routemap to create.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@param value [Array] The routemap match rules.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["route-map {name} {action} {seqno}"] cmds << "match {options}"

set\_set\_statements will set the set values for a specified routemap.
If the specified routemap does not exist, it will be created.

commands route-map action seqno set

@param name [String] The name of the routemap to create.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@param value [Array] The routemap set rules.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["route-map {name} {action} {seqno}"] cmds << "set {options}"

set\_continue will set the continue value for a specified routemap. If
the specified routemap does not exist, it will be created.

commands route-map action seqno continue

@param name [String] The name of the routemap to create.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@param value [Integer] The continue value.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["route-map {name} {action} {seqno}"] cmds << "continue {value}"

set\_description will set the description for a specified routemap. If
the specified routemap does not exist, it will be created.

commands route-map action seqno description

@param name [String] The name of the routemap to create.

@param action [String] Either permit or deny.

@param seqno [Integer] The sequence number.

@param value [String] The description value.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["route-map {name} {action} {seqno}"] cmds << "description
{value}"

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Snmp class provides a class implementation for working with the
nodes SNMP configuration entity. This class presents an abstraction of
the node's snmp configuration from the running config.

@since eos\_version 4.13.7M

get returns the snmp resource Hash that represents the nodes snmp
configuration abstraction from the running config.

@example { location: , contact: , chassis\_id: , source\_interface: }

@return [Hash<Symbol, Object>] Returns the snmp resource as a Hash.

parse\_location scans the running config from the node and parses the
snmp location value if it exists in the configuration. If the snmp
location is not configure, then the DEFAULT\_SNMP\_LOCATION string is
returned. The Hash returned by this method is merged into the snmp
resource Hash returned by the get method.

@api private

@return [Hash<Symbol,Object>] Returns the resource Hash attribute.

parse\_contact scans the running config form the node and parses the
snmp contact value if it exists in the configuration. If the snmp
contact is not configured, then the DEFAULT\_SNMP\_CONTACT value is
returned. The Hash returned by this method is merged into the snmp
resource Hash returned by the get method.

@api private

@return [Hash<Symbol,Object] Returns the resource Hash attribute.

parse\_chassis\_id scans the running config from the node and parses the
snmp chassis id value if it exists in the configuration. If the snmp
chassis id is not configured, then the DEFAULT\_SNMP\_CHASSIS\_ID value
is returned. The Hash returned by this method is intended to be merged
into the snmp resource Hash.

@api private

@return [Hash<Symbol,Object>] Returns the resource Hash attribute.

parse\_source\_interface scans the running config from the node and
parses the snmp source interface value if it exists in the
configuration. If the snmp source interface is not configured, then the
DEFAULT\_SNMP\_SOURCE\_INTERFACE value is returned. The Hash returned by
this method is intended to be merged into the snmmp resource Hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource Hash attribute.

parse\_communities scans the running config from the node and parses all
of the configure snmp community strings. If there are no configured snmp
community strings, the community value is set to an empty array. The
returned hash is intended to be merged into the global snmp resource
hash.

@api private

@return [Hash<Hash>] Returns the resource hash attribute.

parse\_notifications scans the running configuration and parses all of
the snmp trap notifications configuration. It is expected the trap
configuration is in the running config. The returned hash is intended to
be merged into the resource hash.

set\_notification configures the snmp trap notification for the
specified trap. The name option accepts the snmp trap name to configure
or the keyword all to globally enable or disable notifications. If the
optional state argument is not provided then the default state is
default.

@since eos\_version 4.13.7M

commands snmp-server enable traps no snmp-server enable traps default
snmp-server enable traps

@param opts [Hash] The configuration parameters.

@option opts name [String] The name of the trap to configure or the
keyword all. If this option is not specified, then the value of 'all' is
used as the default.

@option opts state [String] The state to configure the trap
notification. Valid values include 'on', 'off' or 'default'. configure
"{state} snmp-server enable traps {name}"

set\_location updates the snmp location value in the nodes running
configuration. If enable is false, then the snmp location value is
negated using the no keyword. If the default keyword is set to true,
then the snmp location value is defaulted using the default keyword. The
default parameter takes precedence over the enable keyword.

@since eos\_version 4.13.7M

commands snmp-server location no snmp-server location default
snmp-server location

@param opts [Hash] The configuration parameters.

@option opts value [string] The snmp location value to configure.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the snmp location value using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_contact updates the snmp contact value in the nodes running
configuration. If enable is false in the opts Hash then the snmp contact
value is negated using the no keyword. If the default keyword is set to
true, then the snmp contact value is defaulted using the default
keyword. The default parameter takes precedence over the enable keyword.

@since eos\_version 4.13.7M

commands snmp-server contact no snmp-server contact default snmp-server
contact

@param opts [Hash] The configuration parameters.

@option opts value [string] The snmp contact value to configure.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the snmp contact value using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_chassis\_id updates the snmp chassis id value in the nodes running
configuration. If enable is false in the opts Hash then the snmp chassis
id value is negated using the no keyword. If the default keyword is set
to true, then the snmp chassis id value is defaulted using the default
keyword. The default keyword takes precedence over the enable keyword.

@since eos\_version 4.13.7M

commands snmp-server chassis-id no snmp-server chassis-id default
snmp-server chassis-id

@param opts [Hash] The configuration parameters

@option opts value [string] The snmp chassis id value to configure

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configures the snmp chassis id value
using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

set\_source\_interface updates the snmp source interface value in the
nodes running configuration. If enable is false in the opts Hash then
the snmp source interface is negated using the no keyword. If the
default keyword is set to true, then the snmp source interface value is
defaulted using the default keyword. The default keyword takes
precedence over the enable keyword.

@since eos\_version 4.13.7M

commands snmp-server source-interface no snmp-server source-interface
default snmp-server source-interface

@param opts [Hash] The configuration parameters.

@option opts value [string] The snmp source interface value to
configure. This method will not ensure the interface is present in the
configuration. @option opts enable [Boolean] If false then the command
is negated. Default is true. @option opts default [Boolean] Configures
the snmp source interface value using the default keyword.

@return [Boolean] Returns true if the command completed successfully.

add\_community adds a new snmp community to the nodes running
configuration. This function is a convenience function that passes the
message to set\_community\_access.

@see set\_community\_access

@param name [String] The name of the snmp community to add to the nodes
running configuration.

@param access [String] Specifies the access level to assign to the new
snmp community. Valid values are 'rw' or 'ro'.

@return [Boolean] Returns true if the command completed successfully.

remove\_community removes the specified community from the nodes running
configuration. If the specified name is not configured, this method will
still return successfully.

@since eos\_version 4.13.7M

commands no snmp-server community

@param name [String] The name of the snmp community to add to the nodes
running configuration.

@return [Boolean] Returns true if the command completed successfully.
configure "no snmp-server community {name}"

set\_community\_acl configures the acl to apply to the specified
community name. When enable is true, it will remove the the named
community and then add the new acl entry.

@since eos\_version 4.13.7M

commands no snmp-server [ro\|rw] snmp-server [ro\|rw]

@param name [String] The name of the snmp community to add to the nodes
running configuration.

@param opts [Hash] The configuration parameters.

@option opts value [String] The name of the acl to apply to the snmp
community in the nodes config. If nil, then the community name allows
access to all objects.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the snmp community name using
the default keyword. Default takes precedence over enable.

@return [Boolean] Returns true if the command completed successfully.
Default is same as negate for this command cmds = ["no snmp-server
community {name}"] cmds << "snmp-server community {name} {access}
{value}" if enable

set\_community\_access configures snmp-server community with designated
name and access values.

@param name [String] The snmp-server community name value.

@param access [String] The snmp-server community access value.

@return [Boolean] Returns true if the command completed successfully.
configure "snmp-server community {name} {access}"

Copyright (c) 2014, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Staticroutes class provides a configuration instance for working
with static routes in EOS.

Returns the static routes configured on the node.

@example { [ { destination: <route\_dest/masklen>, nexthop: next\_hop>,
distance: , tag: , name: }, ... ] }

@return [Array<Hash, Hash>] The method will return all of the configured
static routes on the node as a Ruby array object containing a list of
hashes with each hash describing a route. If there are no static routes
configured, this method will return an empty array.
([^\\s]+):raw-latex:`\s                 `capture destination ([^\\s$]+)
capture next hop IP or egress interface `:raw-latex:`\s`\|$ <\d+>`__
capture metric (distance)
[:raw-latex:`\s`\|$]{1}(?:tag:raw-latex:`\s`(:raw-latex:`\d`+))? catpure
route tag [:raw-latex:`\s`\|$]{1}(?:name:raw-latex:`\s`(.+))? capture
route name

Creates a static route in EOS. May add or overwrite an existing route.

commands ip route [router\_ip] [distance] [tag ][name ]

@param destination [String] The destination and prefix matching the
route(s). Ex '192.168.0.2/24'.

@param nexthop [String] The nexthop for this entry, which may an IP
address or interface name.

@param opts [Hash] Additional options for the route entry.

@option opts router\_ip [String] If nexthop is an egress interface,
router\_ip specifies the router to which traffic will be forwarded.

@option opts distance [String] The administrative distance (metric).

@option opts tag [String] The route tag.

@option opts name [String] A route name.

@return [Boolean] Returns True on success, otherwise False. cmd = "ip
route {destination} {nexthop}" cmd << " {opts[:router\_ip]}" if
opts[:router\_ip] cmd << " {opts[:distance]}" if opts[:distance] cmd <<
" tag {opts[:tag]}" if opts[:tag] cmd << " name {opts[:name]}" if
opts[:name]

Removes a given route from EOS. May remove multiple routes if nexthop is
not specified.

commands no ip route [nexthop]

@param destination [String] The destination and prefix matching the
route(s). Ex '192.168.0.2/24'.

@param nexthop [String] The nexthop for this entry, which may an IP
address or interface name.

@return [Boolean] Returns True on success, otherwise False. cmd = "no ip
route {destination}" cmd << " {nexthop}" if nexthop

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Stp class provides a base class instance for working with the EOS
spanning-tree configuration.

get returns the current stp configuration parsed from the nodes current
running configuration.

@example { mode: instances: { : { priority: } } interfaces: { : {
portfast: , portfast\_type: , bpduguard: } } }

@return [Hash] returns a Hash of attributes derived from eAPI.

parse\_mode scans the nodes running configuration and extracts the value
of the spanning-tree mode. The spanning tree mode is expected to be
always be available in the running config. The return value is intended
to be merged into the stp resource hash.

@api private

@return [Hash<Symbol, Object>] Resource hash attribute.

instances returns a memoized instance of StpInstances for configuring
individual stp instances.

@return [StpInstances] an instance of StpInstances class.

interfaces returns a memoized instance of StpInterfaces for configuring
individual stp interfaces.

@return [StpInterfaces] an instance of StpInterfaces class.

set\_mode configures the stp mode in the global nodes running
configuration. If the enable option is false, then the stp mode is
configured with the no keyword argument. If the default option is
specified then the mode is configured with the default keyword argument.
The default keyword argument takes precedence over the enable option if
both are provided.

@since eos\_version 4.13.7M

commands spanning-tree mode no spanning-tree mode default spanning-tree
mode

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the stp mode to in
the nodes current running configuration.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the stp mode value using the
default keyword.

@return [Boolean] returns true if the command completed successfully.

The StpInstances class provides a class instance for working with
spanning-tree instances in EOS

get returns the specified stp instance config parsed from the nodes
current running configuration.

@example { priority: }

@param inst [String] The named stp instance to return.

@return [nil, Hash<Symbol, Object] Returns the stp instance config as a
resource hash. If the instances is not configured this method will
return a nil object.

getall returns all configured stp instances parsed from the nodes
running configuration. The return hash is keyed by the instance
identifier value.

@example { : { priority: }, : { priority: }, ... }

@return [Hash<Symbol, Object>] Returns all configured stp instances
found in the nodes running configuration.

parse\_instances will scan the nodes current configuration and extract
the list of configured mst instances. If no instances are configured
then this method will return an empty array.

@api private

@return [Array<String>] Returns an Array of configured stp instances.

parse\_priority will scan the nodes current configuration and extract
the stp priority value for the given stp instance. If the stp instance
priority is not configured, the priority value will be set using
DEFAULT\_STP\_PRIORITY. The returned hash is intended to be merged into
the resource hash.

@api private

@return [Hash<Symbol, Object>] Resource hash attribute. priority\_re =
/(?<=^spanning-tree:raw-latex:`\smst`:raw-latex:`\s{inst}`:raw-latex:`\spriority`:raw-latex:`\s`)(.+$)/x

Deletes a configured MST instance.

@param inst [String] The MST instance to delete.

@return [Boolean] True if the commands succeed otherwise False.
configure ['spanning-tree mst configuration', "no instance {inst}",

Configures the spanning-tree MST priority.

@param inst [String] The MST instance to configure.

@param opts [Hash] The configuration parameters for the priority.

@option opts value [string] The value to set the priority to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] True if the commands succeed otherwise False. cmd =
"default spanning-tree mst {inst} priority" cmd = "spanning-tree mst
{inst} priority {value}" cmd = "no spanning-tree mst {inst} priority"

The StpInterfaces class provides a class instance for working with
spanning-tree interfaces in EOS.

get returns the configured stp interfaces from the nodes running
configuration as a resource hash. If the specified interface is not
configured as a switchport then this method will return nil.

@example { portfast: , portfast\_type: , bpduguard: }

@param name [String] The interface name to return a resource for from
the nodes configuration.

@return [nil, Hash<Symbol, Object>] Returns the stp interface as a
resource hash. config = get\_block("interface {name}")

getall returns all of the configured stp interfaces parsed from the
nodes current running configuration. The returned hash is keyed by the
interface name.

@example { : { portfast: , portfast\_type: , bpduguard: }, : { portfast:
, portfast\_type: , bpduguard: }, ... }

@return [Hash<Symbol, Object>] Returns the stp interfaces config as a
resource hash from the nodes running configuration.

parse\_portfast scans the supplied interface configuration block and
parses the value stp portfast. The value of portfast is either enabled
(true) or disabled (false).

@api private

@return [Hash<Symbol, Object>] Resource hash attribute.

parse\_portfast\_type scans the supplied interface configuration block
and parses the value stp portfast type. The value of portfast type is
either not set which implies normal (default), edge, or network.

@api private

@return [Hash<Symbol, Object>] Resource hash attribute.

parse\_bpduguard scans the supplied interface configuration block and
parses the value of stp bpduguard. The value of bpduguard is either
disabled (false) or enabled (true).

@api private

@return [Hash<Symbol, Object>] Resource hash attribute.

Configures the interface portfast value.

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for portfast.

@option opts value [Boolean] The value to set portfast.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] True if the commands succeed otherwise False.

Configures the interface portfast type value

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for portfast type.

@option opts value [String] The value to set portfast type to. The value
must be set for calls to this method.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] True if the commands succeed otherwise False. cmds =
"default spanning-tree portfast {value}" cmds = "spanning-tree portfast
{value}" cmds = "no spanning-tree portfast {value}"

Configures the interface bpdu guard value

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for bpduguard.

@option opts value [Boolean] The value to set bpduguard.

@option opts enable [Boolean] If false then the bpduguard is disabled.
If true then the bpduguard is enabled. Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] True if the commands succeed otherwise False.

Copyright (c) 2014,2015 Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Switchport class provides a base class instance for working with
logical layer-2 interfaces.

Retrieves the properties for a logical switchport from the
running-config using eAPI.

Example { "name": , "mode": [access, trunk], "trunk\_allowed\_vlans":
array "trunk\_native\_vlan": , "access\_vlan": , "trunk\_groups": array
}

@param name [String] The full name of the interface to get. The
interface name must be the full interface (ie Ethernet, not Et).

@return [Hash] Returns a hash that includes the switchport properties.
config = get\_block("interface {name}")

parse\_mode parses switchport mode from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_access\_vlan parses access vlan from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_trunk\_native\_vlan parses trunk native vlan from the provided
config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_trunk\_allowed\_vlans parses trunk allowed vlan from the provided
config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_trunk\_groups parses trunk group values from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

Retrieves all switchport interfaces from the running-config.

@example { : { mode: , access\_vlan: , trunk\_native\_vlan: ,
trunk\_allowed\_vlans: , trunk\_groups: }, : { mode: , access\_vlan: ,
trunk\_native\_vlan: , trunk\_allowed\_vlans: , trunk\_groups: }, ... }

@return [Array] Returns an array of switchport hashes.

Creates a new logical switchport interface in EOS.

@param name [String] The name of the logical interface.

@return [Boolean] Returns True if it succeeds otherwise False. configure
["interface {name}", 'no ip address', 'switchport']

Deletes a logical switchport interface from the running-config.

@param name [String] The name of the logical interface.

@return [Boolean] Returns True if it succeeds otherwise False. configure
["interface {name}", 'no switchport']

Defaults a logical switchport interface in the running-config.

@param name [String] The name of the logical interface.

@return [Boolean] Returns True if it succeeds otherwise False. configure
["interface {name}", 'default switchport']

Configures the switchport mode for the specified interface.

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for the interface.

@option opts value [string] The value to set the mode to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] Returns True if the commands succeed otherwise False.

set\_trunk\_allowed\_vlans configures the list of vlan ids that are
allowed on the specified trunk port. If the enable option is set to
false, then the allowed trunks is configured using the no keyword. If
the default keyword is provided then the allowed trunks is configured
using the default keyword. The default option takes precedence over the
enable option if both are specified.

@since eos\_version 4.13.7M

commands switchport trunk allowed vlan add no switchport trunk allowed
vlan default switchport trunk allowed vlan

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for the interface.

@option ots value [Array] The list of vlan ids to configure on the
switchport to be allowed. This value must be an array of valid vlan ids.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option default [Boolean] Configures the switchport trunk allowed vlans
command using the default keyword. Default takes precedence over enable.

@return [Boolean] Returns true if the commands complete successfully.
"switchport trunk allowed vlan {value}"]

Configures the trunk port native vlan for the specified interface. This
value is only valid if the switchport mode is configure as trunk.

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for the interface.

@option opts value [string] The value of the trunk native vlan.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.
Default takes precedence over enable.

@return [Boolean] Returns True if the commands succeed otherwise False.

Configures the access port vlan for the specified interface. This value
is only valid if the switchport mode is configure in access mode.

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for the interface.

@option opts value [string] The value of the access vlan.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default
Default takes precedence over enable.

@return [Boolean] Returns True if the commands succeed otherwise False.

Configures the trunk group vlans for the specified interface. Trunk
groups not currently set are added and trunk groups currently configured
but not in the passed in value array are removed.

@param name [String] The name of the interface to configure.

@param opts [Hash] The configuration parameters for the interface.

@option opts value [string] Set of values to configure the trunk group.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default
Default takes precedence over enable.

@return [Boolean] Returns True if the commands succeed otherwise False.
Add trunk groups that are not currently in the list. cmds << "switchport
trunk group {group}" Remove trunk groups that are not in the new list.
cmds << "no switchport trunk group {group}"

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace

Api is module namespace for working with the EOS command API.

The System class configures the node system services such as hostname
and domain name.

Returns the system settings for hostname, iprouting, and banners.

@example { hostname: , iprouting: , banner\_motd: , banner\_login: }

@return [Hash] A Ruby hash object that provides the system settings as
key/value pairs.

parse\_hostname parses hostname values from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] The resource hash attribute.

parse\_iprouting parses ip routing from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] The resource hash attribute.

Parses the global config and returns the value for both motd and login
banners.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] The resource hash attribute. If the
banner is not set it will return a value of None for that key.

Configures the system hostname value in the running-config.

@param opts [Hash] The configuration parameters.

@option opts value [string] The value to set the hostname to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] If true configure the command using the
default keyword. Default is false.

@return [Boolean] Returns true if the command completed successfully.

Configures the state of global ip routing.

@param opts [Hash] The configuration parameters.

@option opts enable [Boolean] True if ip routing should be enabled or
False if ip routing should be disabled. Default is true.

@option opts default [Boolean] If true configure the command using the
default keyword. Default is false.

@return [Boolean] Returns true if the command completed successfully.

Configures system banners.

@param banner\_type [String] Banner to be changed (likely either login
or motd).

@param opts [Hash] The configuration parameters.

@option opts value [string] The value to set for the banner.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] If true configure the command using the
default keyword. Default is false.

@return [Boolean] Returns true if the command completed successfully.
cmd\_string = "banner {banner\_type}"

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

Tacacs provides instance methods to retrieve and set tacacs
configuration values. Regular expression to extract a tacacs server's
attributes from the running-configuration text. The explicit [ ] spaces
enable line wrapping and indentation with the /x flag. Default Tacacs
TCP port

getall Returns an Array with a single resource Hash describing the
current state of the global tacacs configuration on the target device.
This method is intended to be used by a provider's instances class
method.

@example { name: , enable: , key: , key\_format: , timeout: }

@return [Array<Hash>] Single element Array of resource hashes.

parse\_global\_key takes a running configuration as a string and parses
out the radius global key and global key format if it exists in the
configuration. An empty Hash is returned if there is no global key
configured. The intent of the Hash is to be merged into a property hash.

@api private

@return [Hash<Symbol,Object>] Returns the resource hash attributes.

parse\_global\_timeout takes a running configuration as a string and
parses out the tacacs global timeout if it exists in the configuration.
An empty Hash is returned if there is no global timeout value
configured. The intent of the Hash is to be merged into a property hash.

@api private

@return [Hash<Symbol,Object>] Returns the resource hash attributes.

servers returns an Array of tacacs server resource hashes. Each hash
describes the current state of the tacacs server and is suitable for use
in initializing a tacacs\_server provider.

The resource hash returned contains the following information:

-  hostname: hostname or ip address, part of the identifier.
-  port: (Fixnum) TCP port of the server, part of the identifier.
-  key: (String) the key either in plain text or hashed format.
-  key\_format: (Fixnum) e.g. 0 or 7.
-  timeout: (Fixnum) seconds before the timeout period ends.
-  multiplex: (Boolean) true when configured to make requests through a
   single connection.

@api public

@return [Array<Hash<Symbol,Object>>] Array of resource hashes.

set\_global\_key configures the tacacs default key. This method maps to
the ``tacacs-server key`` EOS configuration command, e.g.
``tacacs-server  key 7 070E234F1F5B4A``.

@option opts key [String] ('070E234F1F5B4A') The key value.

@option opts key\_format [Fixnum] (7) The key format, 0 for plain text
and 7 for a hashed value. 7 will be assumed if this option is not
provided.

@api public

@return [Boolean] Returns true if no errors. result =
api.config("tacacs-server key {format} {key}")

set\_timeout configures the tacacs default timeout. This method maps to
the ``tacacs-server timeout`` setting.

@param opts [Hash] The configuration parameters.

@option opts value [string] The value to set the timeout to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@api public

@return [Boolean] Returns true if no errors.

update\_server configures a tacacs server resource on the target device.
This API method maps to the ``tacacs server host`` command, e.g.
``tacacs-server host 1.2.3.4 single-connection port 4949 timeout 6 key 7  06070D221D1C5A``.

@api public

@param opts [Hash] The configuration parameters.

@option opts key\_format [Integer] The format for the key.

@option opts hostname [String] The host value.

@option opts multiplex [String] Defines single-connection.

@option opts port [String] The port value.

@option opts timeout [String] The timeout value.

@option opts key [String] The key value.

@return [Boolean] Returns true if there are no errors. cmd =
"tacacs-server host {opts[:hostname]}" cmd << " port {opts[:port]}" if
opts[:port] cmd << " timeout {opts[:timeout]}" if opts[:timeout] cmd <<
" key {key\_format} {opts[:key]}" if opts[:key]

remove\_server removes the tacacs server identified by the hostname, and
port attributes.

@api public

@param opts [Hash] The configuration parameters.

@option hostname [String] The host value.

@option port [String] The port value.

@return [Boolean] Returns true if there are no errors. cmd = "no
tacacs-server host {opts[:hostname]}" cmd << " port {opts[:port]}" if
opts[:port]

Copyright (c) 2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Users class provides configuration of local user resources for an
EOS node. The regex used here parses the running configuration to find
all username entries. There is extra logic in the regular expression to
store the username as 'user' and then creates a back reference to find a
following configuration line that might contain the users sshkey.

get returns the local user configuration.

@example { name: , privilege: , role: , nopassword: , encryption:
<'cleartext', 'md5', 'sha512'> secret: , sshkey: }

@param name [String] The user name to return a resource for from the
nodes configuration

@return [nil, Hash<Symbol, Object>] Returns the user resource as a Hash.
If the specified user name is not found in the nodes current
configuration a nil object is returned. The regex used here parses the
running configuration to find one username entry. user\_re =
Regexp.new(/^username:raw-latex:`\s`+(?{name}):raw-latex:`\s`+
(username:raw-latex:`\s`+{name}:raw-latex:`\s`+

getall returns a collection of user resource hashes from the nodes
running configuration. The user resource collection hash is keyed by the
unique user name.

@example [ <username>: { name: <string>, privilege: <integer>, role:
<string>, nopassword: <boolean>, encryption: <'cleartext', 'md5',
'sha512'> secret: <string>, sshkey: <string> }, <username>: { name:
<string>, privilege: <integer>, role: <string>, nopassword: <boolean>,
encryption: <'cleartext', 'md5', 'sha512'> secret: <string>, sshkey:
<string> }, ... ]

@return [Hash<Symbol, Object>] Returns a hash that represents the entire
user collection from the nodes running configuration. If there are no
user names configured, this method will return an empty hash.

parse\_user\_entry maps the tokens find to the hash entries.

@api private

@param user [Array] An array of values returned from the regular
expression scan of the nodes configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute. Map
the encryption value if set, if there is no mapping then just return the
value.

create will create a new user name resource in the nodes current
configuration with the specified user name. Creating users require
either a secret (password) or the nopassword keyword to be specified.
Optional parameters can be passed in to initialize user name specific
settings.

@since eos\_version 4.13.7M

commands username nopassword privilege role username secret [0,5,sha512]
...

@param name [String] The name of the user to create.

@param opts [hash] Optional keyword arguments.

@option opts nopassword [Boolean] Configures the user to be able to
authenticate without a password challenge.

@option opts secret [String] The secret (password) to assign to this
user.

@option opts encryption [String] Specifies how the secret is encoded.
Valid values are "cleartext", "md5", "sha512". The default is
"cleartext".

@option opts privilege [String] The privilege value to assign to the
user.

@option opts role [String] The role value to assign to the user.

@option opts sshkey [String] The sshkey value to assign to the user.

@return [Boolean] Returns true if the command completed successfully.
cmd = "username {name}" cmd << " privilege {opts[:privilege]}" if
opts[:privilege] cmd << " role {opts[:role]}" if opts[:role] Map the
encryption value if set, if there is no mapping then just return the
value. fail ArgumentError, "invalid encryption value: {enc}" cmd << "
secret {enc} {opts[:secret]}" cmds << "username {name} sshkey
{opts[:sshkey]}" if opts[:sshkey]

delete will delete an existing user name from the nodes current running
configuration. If the delete method is called and the user name does not
exist, this method will succeed.

@since eos\_version 4.13.7M

commands no username

@param name [String] The user name to delete from the node.

@return [Boolean] Returns true if the command completed successfully.
configure("no username {name}")

default will configure the user name using the default keyword. This
command has the same effect as deleting the user name from the nodes
running configuration.

@since eos\_version 4.13.7M

commands default username

@param name [String] The user name to default in the nodes
configuration.

@return [Boolean] Returns true if the command complete successfully.
configure("default username {name}")

set\_privilege configures the user privilege value for the specified
user name in the nodes running configuration. If enable is false in the
opts keyword Hash then the name value is negated using the no keyword.
If the default keyword is set to true, then the privilege value is
defaulted using the default keyword. The default keyword takes
precedence over the enable keyword

@since eos\_version 4.13.7M

commands username privilege no username privilege default username
privilege

@param name [String] The user name to default in the nodes
configuration.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The privilege value to assign to the user.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the user privilege value using
the default keyword.

@return [Boolean] Returns true if the command completed successfully.
configure(command\_builder("username {name} privilege", opts))

set\_role configures the user role value for the specified user name in
the nodes running configuration. If enable is false in the opts keyword
Hash then the name value is negated using the no keyword. If the default
keyword is set to true, then the role value is defaulted using the
default keyword. The default keyword takes precedence over the enable
keyword

@since eos\_version 4.13.7M

commands username role no username role default username role

@param name [String] The user name to default in the nodes
configuration.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The role value to assign to the user.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the user role value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.
configure(command\_builder("username {name} role", opts))

set\_sshkey configures the user sshkey value for the specified user name
in the nodes running configuration. If enable is false in the opts
keyword Hash then the name value is negated using the no keyword. If the
default keyword is set to true, then the sshkey value is defaulted using
the default keyword. The default keyword takes precedence over the
enable keyword.

@since eos\_version 4.13.7M

commands username sshkey no username sshkey default username sshkey

@param name [String] The user name to default in the nodes
configuration.

@param opts [Hash] Optional keyword arguments

@option opts value [String] The sshkey value to assign to the user

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the user sshkey value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.
configure(command\_builder("username {name} sshkey", opts))

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Varp class provides an instance for working with the global VARP
configuration of the node.

Returns the global VARP configuration from the node.

@example { mac\_address: , interfaces: { : { addresses: }, : {
addresses: }, ... } }

@return [Hash] A Ruby hash object that provides the Varp settings as key
/ value pairs.

parse\_mac\_address parses mac-address values from the provided config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute. ip
virtual-router mac-address value will always be stored in
aa:bb:cc:dd:ee:ff format.

Configure the VARP virtual-router mac-address value.

@param opts [Hash] The configuration parameters.

@option opts value [string] The value to set the mac-address to.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] Returns true if the command completed successfully.

The VarpInterfaces class provides an instance for working with the
global VARP interface configuration of the node.

Returns a single VARP interface configuration.

@example { "addresses": array }

@param name [String] The interface name to return the configuration
values for. This must be the full interface identifier.

@return [nil, Hash<String, String>] A Ruby hash that represents the VARP
interface configuration. A nil object is returned if the specified
interface is not configured config = get\_block("^interface {name}")

Returns the collection of MLAG interfaces as a hash index by the
interface name.

@example { : { addresses: }, : { addresses: }, ... }

@return [nil, Hash<String, String>] A Ruby hash that represents the MLAG
interface configuration. A nil object is returned if no interfaces are
configured.

parse\_addresses parses ip virtual-router address from the provided
config.

@api private

@param config [String] The configuration block returned from the node's
running configuration.

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

The set\_addresses method assigns one or more virtual IPv4 address to
the specified VLAN interface. All existing addresses are removed before
the ones in value are added.

@param name [String] The name of the interface. The name argument must
be the full interface name. Valid interfaces are restricted to VLAN
interfaces.

@param opts [Hash] The configuration parameters.

@option opts value [Array] Array of IPv4 addresses to add to the virtual
router.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] The value should be set to default.

@return [Boolean] True if the commands succeeds otherwise False. cmds =
["interface {name}"] cmds << "ip virtual-router address {addr}"

The add\_address method assigns one virtual IPv4 address.

@param name [String] The name of the interface. The name argument must
be the full interface name. Valid interfaces are restricted to VLAN
interfaces.

@param value [string] The virtual router address to add.

@return [Boolean] True if the commands succeeds otherwise False.
configure(["interface {name}", "ip virtual-router address {value}"])

The remove\_address method removes one virtual IPv4 address.

@param name [String] The name of the interface. The name argument must
be the full interface name. Valid interfaces are restricted to VLAN
interfaces.

@param value [string] The virtual router address to remove.

@return [Boolean] True if the commands succeeds otherwise False.
configure(["interface {name}", "no ip virtual-router address {value}"])

Copyright (c) 2014,2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Rbeapi toplevel namespace.

Api is module namespace for working with the EOS command API.

The Vlan class provides a class implementation for working with the
collection of Vlans on the node. This class presents an abstraction of
the nodes configured vlan id's from the running configuration.

@since eos\_version 4.13.7M

get returns the specified vlan resource Hash that represents the nodes
current vlan configuration.

@example { name: , state: , trunk\_groups: array[<string] }

@param id [String] The vlan id to return a resource for from the nodes
configuration.

@return [nil, Hash<Symbol, Object>] Returns the vlan resource as a Hash.
If the specified vlan id is not found in the nodes current configuration
a nil object is returned. config = get\_block("vlan {id}")

getall returns the collection of vlan resources from the nodes running
configuration as a hash. The vlan resource collection hash is keyed by
the unique vlan id.

@example { : { name: , state: , trunk\_groups: array[<string] }, : {
name: , state: , trunk\_groups: array[<string] }, ... }

@see get Vlan resource example

@return [Hash<Symbol, Object>] Returns a hash that represents the entire
vlan collection from the nodes running configuration. If there are no
vlans configured, this method will return an empty hash.

parse\_name scans the provided configuration block and parses the vlan
name value. The vlan name should always return a value from the running
configuration. The return value is intended to be merged into the
resource hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_state scans the provided configuration block and parses the vlan
state value. The vlan state should always return a value from the nodes
running configuration. The return hash is intended to be merged into the
resource hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

parse\_trunk\_groups scans the provided configuration block and parses
the trunk groups. If no trunk groups are found in the nodes running
configuration then an empty array is returned as the value. The return
hash is intended to be merged into the resource hash.

@api private

@return [Hash<Symbol, Object>] Returns the resource hash attribute.

create will create a new vlan resource in the nodes current
configuration with the specified vlan id. If the create method is called
and the vlan id already exists, this method will still return true.

@since eos\_version 4.13.7M

commands vlan

@param id [String, Integer] The vlan id to create on the node. The vlan
id must be in the valid range of 1 to 4094.

@return [Boolean] Returns true if the command completed successfully.
configure("vlan {id}")

delete will delete an existing vlan resource from the nodes current
running configuration. If the delete method is called and the vlan id
does not exist, this method will succeed.

@since eos\_version 4.13.7M

commands no vlan

@param id [String, Integer] The vlan id to delete from the node. The id
value should be in the valid range of 1 to 4094.

@return [Boolean] Returns true if the command completed successfully.
configure("no vlan {id}")

default will configure the vlan using the default keyword. This command
has the same effect as deleting the vlan from the nodes running
configuration.

@since eos\_version 4.13.7M

commands default vlan

@param id [String, Integer] The vlan id to default in the nodes
configuration. Ths vid value should be in the valid range of 1 to 4094.

@return [Boolean] Returns true if the command complete successfully.
configure("default vlan {id}")

set\_name configures the name value for the specified vlan id in the
nodes running configuration. If enable is false in the opts keyword Hash
then the name value is negated using the no keyword. If the default
keyword is set to true, then the name value is defaulted using the
default keyword. The default keyword takes precedence over the enable
keyword.

@since eos\_version 4.13.7M

commands vlan name no name default name

@param id [String, Integer] The vlan id to apply the configuration to.
The id value should be in the valid range of 1 to 4094.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the vlan name to in
the node configuration. The name parameter accepts a-z, 0-9 and \_.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the vlan name value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.
cmds = ["vlan {id}", cmd]

set\_state configures the state value for the specified vlan id in the
nodes running configuration. If enable is set to false in the opts
keyword Hash then the state value is negated using the no keyword. If
the default keyword is set to true, then the state value is defaulted
using the default keyword. The default keyword takes precedence over the
enable keyword

@since eos\_version 4.13.7M

commands vlan state [active, suspend] no state default state

@param id [String, Integer] The vlan id to apply the configuration to.
The id value should be in the valid range of 1 to 4094.

@param opts [Hash] Optional keyword arguments.

@option opts value [String] The value to configure the vlan state to in
the node's configuration. Accepted values are 'active' or 'suspend'.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the vlan state value using the
default keyword.

@return [Boolean] Returns true if the command completed successfully.

@raise [ArgumentError] if the value is not in the accept list of values.
cmds = ["vlan {id}", cmd]

add\_trunk\_group adds a new trunk group value to the specified vlan id
in the nodes running configuration. The trunk group name value accepts
a-z 0-9 and \_.

@since version 4.13.7M

commands vlan trunk group

@param id [String, Integer] The vlan id to apply the configuration to.
the id value should be in the range of 1 to 4094

@param value [String] The value to add to the vlan id configuration on
the node.

@return [Boolean] Returns true if the command completed successfully.
configure(["vlan {id}", "trunk group {value}"])

remove\_trunk\_group removes the specified trunk group value from the
specified vlan id in the node's configuration. If the trunk group name
does not exist, this method will return success

@since eos\_version 4.13.7M

commands vlan no trunk group

@param id [String, Integer] The vlan id to apply the configuration to.
the id value should be in the range of 1 to 4094.

@param value [String] The value to remove from the list of trunk group
names configured for the specified vlan.

configure(["vlan {id}", "no trunk group {value}"])

Copyright (c) 2015, Arista Networks, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of Arista Networks nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ARISTA NETWORKS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.

Eos is the toplevel namespace for working with Arista EOS nodes.

Api is module namespace for working with the EOS command API.

The Vrrp class manages the set of virtual routers. rubocop:disable
Metrics/ClassLength

get returns the all the virtual router IPs for the given layer 3
interface name from the nodes current configuration.

rubocop:disable Metrics/MethodLength

@example { 1: { enable: primary\_ip: priority: description:
secondary\_ip: [ , ] ip\_version: timers\_advertise:
mac\_addr\_adv\_interval: preempt: preempt\_delay\_min:
preempt\_delay\_reload: delay\_reload: track: [ { name: 'Ethernet3',
action: 'decrement', amount: 33 }, { name: 'Ethernet2', action:
'decrement', amount: 22 }, { name: 'Ethernet2', action: 'shutdown' } ] }
}

@param name [String] The layer 3 interface name.

@return [nil, Hash<Symbol, Object>] Returns the VRRP resource as a Hash
with the virtual router ID as the key. If the interface name does not
exist then a nil object is returned. config = get\_block("^interface
{name}") Parse the vrrp configuration for the vrid(s) in the list

getall returns the collection of virtual router IPs for all the layer 3
interfaces from the nodes running configuration as a hash. The resource
collection hash is keyed by the ACL name.

@example { 'Vlan100': { 1: { data }, 250: { data }, }, 'Vlan200': { 2: {
data }, 250: { data }, } }

@return [nil, Hash<Symbol, Object>] Returns a hash that represents the
entire virtual router IPs collection for all the layer 3 interfaces from
the nodes running configuration. If there are no virtual routers
configured, this method will return an empty hash.

parse\_primary\_ip scans the nodes configurations for the given virtual
router id and extracts the primary IP.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'primary\_ip', String>] Where string is the IPv4 address
or nil if the value is not set. match =
config.scan(/^:raw-latex:`\s`+vrrp {vrid} ip
(:raw-latex:`\d`+.:raw-latex:`\d`+.:raw-latex:`\d`+.:raw-latex:`\d`+)$/)

parse\_priority scans the nodes configurations for the given virtual
router id and extracts the priority value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'priority', Integer>] The priority is between <1-255> or
nil if the value is not set. match = config.scan(/^:raw-latex:`\s`+vrrp
{vrid} priority (:raw-latex:`\d`+)$/)

parse\_timers\_advertise scans the nodes configurations for the given
virtual router id and extracts the timers advertise value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [nil, Hash<'timers\_advertise', Integer>] The timers\_advertise
is between <1-255> or nil if the value is not set. match =
config.scan(/^:raw-latex:`\s`+vrrp {vrid} timers advertise
(:raw-latex:`\d`+)$/)

parse\_preempt scans the nodes configurations for the given virtual
router id and extracts the preempt value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [nil, Hash<'preempt', Integer>] The preempt is between <1-255>
or nil if the value is not set. match =
config.scan(/^:raw-latex:`\s`+vrrp {vrid} preempt$/)

parse\_enable scans the nodes configurations for the given virtual
router id and extracts the enable value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'enable', Boolean>] match =
config.scan(/^:raw-latex:`\s`+vrrp {vrid} shutdown$/)

parse\_secondary\_ip scans the nodes configurations for the given
virtual router id and extracts the secondary\_ip value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [nil, Hash<'secondary\_ip', Array<Strings>>] Returns an empty
array if the value is not set. regex = "vrrp {vrid} ip" matches =
config.scan(/^:raw-latex:`\s`+{regex}
(:raw-latex:`\d`+.:raw-latex:`\d`+.:raw-latex:`\d`+.:raw-latex:`\d`+)
secondary$/)

parse\_description scans the nodes configurations for the given virtual
router id and extracts the description.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [nil, Hash<'secondary\_ip', String>] Returns nil if the value is
not set. match = config.scan(/^:raw-latex:`\s`+vrrp {vrid}
description:raw-latex:`\s`+(.\*):raw-latex:`\s*`$/)

parse\_track scans the nodes configurations for the given virtual router
id and extracts the track entries.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'track', Array<Hashes>] Returns an empty array if the
value is not set. An example array of hashes follows: { name:
'Ethernet3', action: 'decrement', amount: 33 }, { name: 'Ethernet2',
action: 'decrement', amount: 22 }, { name: 'Ethernet2', action:
'shutdown' } pre = "vrrp {vrid} track "
config.scan(/^:raw-latex:`\s`+{pre}(:raw-latex:`\S`+)
(decrement\|shutdown):raw-latex:`\s*`(?:(:raw-latex:`\d`+\ :math:`|`))/)

parse\_ip\_version scans the nodes configurations for the given virtual
router id and extracts the IP version.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'ip\_version', Integer>] Returns nil if the value is not
set. match = config.scan(/^:raw-latex:`\s`+vrrp {vrid} ip version
(:raw-latex:`\d`+)$/)

parse\_mac\_addr\_adv\_interval scans the nodes configurations for the
given virtual router id and extracts the mac address advertisement
interval.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'mac\_addr\_adv\_interval', Integer>] Returns nil if the
value is not set. regex = "vrrp {vrid} mac-address
advertisement-interval" match = config.scan(/^:raw-latex:`\s`+{regex}
(:raw-latex:`\d`+)$/)

parse\_preempt\_delay\_min scans the nodes configurations for the given
virtual router id and extracts the preempt delay minimum value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'preempt\_delay\_min', Integer>] Returns nil if the value
is not set. match = config.scan(/^:raw-latex:`\s`+vrrp {vrid} preempt
delay minimum (:raw-latex:`\d`+)$/)

parse\_preempt\_delay\_reload scans the nodes configurations for the
given virtual router id and extracts the preempt delay reload value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'preempt\_delay\_reload', Integer>] Returns nil if the
value is not set. match = config.scan(/^:raw-latex:`\s`+vrrp {vrid}
preempt delay reload (:raw-latex:`\d`+)$/)

parse\_delay\_reload scans the nodes configurations for the given
virtual router id and extracts the delay reload value.

@api private

@param config [String] The interface config.

@param vrid [String] The virtual router id.

@return [Hash<'delay\_reload', Integer>] Returns empty hash if the value
is not set. match = config.scan(/^:raw-latex:`\s`+vrrp {vrid} delay
reload (:raw-latex:`\d`+)$/)

create will create a new virtual router ID resource for the interface in
the nodes current. If the create method is called and the virtual router
ID already exists for the interface, this method will still return true.
Create takes optional parameters, but at least one parameter needs to be
set or the command will fail.

@since eos\_version 4.13.7M

commands interface vrrp ...

@param name [String] The layer 3 interface name.

@param vrid [String] The virtual router id.

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] Enable the virtual router.

@option opts primary\_ip [String] The primary IPv4 address.

@option opts priority [Integer] The priority setting for a virtual
router.

@option opts description [String] Associates a text string to a virtual
router.

@option opts secondary\_ip [Array] The secondary IPv4 address to the
specified virtual router.

@option opts ip\_version [Integer] Configures the VRRP version for the
VRRP router.

@option opts timers\_advertise [Integer] The interval between successive
advertisement messages that the switch sends to routers in the specified
virtual router ID.

@option opts mac\_addr\_adv\_interval [Integer] Specifies interval in
seconds between advertisement packets sent to VRRP group members.

@option opts preempt [Boolean] A virtual router preempt mode setting.
When preempt mode is enabled, if the switch has a higher priority it
will preempt the current master virtual router. When preempt mode is
disabled, the switch can become the master virtual router only when a
master virtual router is not present on the subnet, regardless of
priority settings.

@option opts preempt\_delay\_min [Integer] Interval in seconds between
VRRP preempt event and takeover. Minimum delays takeover when VRRP is
fully implemented.

@option opts preempt\_delay\_reload [Integer] Interval in seconds
between VRRP preempt event and takeover. Reload delays takeover after
initialization following a switch reload.

@option opts delay\_reload [Integer] Delay between system reboot and
VRRP initialization.

@option opts track [Array] The track hash contains the name of an
interface to track, the action to take on state-change of the tracked
interface, and the amount to decrement the priority.

@return [Boolean] Returns true if the command completed successfully.
cmds << "no vrrp {vrid} shutdown" cmds << "vrrp {vrid} shutdown" cmds <<
"vrrp {vrid} ip {opts[:primary\_ip]}" if opts.key?(:primary\_ip) cmds <<
"vrrp {vrid} priority {opts[:priority]}" cmds << "vrrp {vrid}
description {opts[:description]}" cmds << "vrrp {vrid} ip version
{opts[:ip\_version]}" cmds << "vrrp {vrid} timers advertise
{opts[:timers\_advertise]}" cmds << "vrrp {vrid} mac-address
advertisement-interval {val}" cmds << "vrrp {vrid} preempt" cmds << "no
vrrp {vrid} preempt" cmds << "vrrp {vrid} preempt delay minimum {val}"
cmds << "vrrp {vrid} preempt delay reload {val}" cmds << "vrrp {vrid}
delay reload {opts[:delay\_reload]}"

delete will delete the virtual router ID on the interface from the nodes
current running configuration. If the delete method is called and the
virtual router id does not exist on the interface, this method will
succeed.

@since eos\_version 4.13.7M

commands interface no vrrp

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@return [Boolean] Returns true if the command completed successfully.
configure\_interface(name, "no vrrp {vrid}")

default will default the virtual router ID on the interface from the
nodes current running configuration. This command has the same effect as
deleting the virtual router id from the interface in the nodes running
configuration. If the default method is called and the virtual router id
does not exist on the interface, this method will succeed.

@since eos\_version 4.13.7M

commands interface default vrrp

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@return [Boolean] Returns true if the command complete successfully.
configure\_interface(name, "default vrrp {vrid}")

set\_shutdown enables and disables the virtual router.

commands interface {no \| default} vrrp shutdown

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] If enable is true then the virtual router
is administratively enabled for the interface and if enable is false
then the virtual router is administratively disabled for the interface.
Default is true.

@option opts default [Boolean] Configure shutdown using the default
keyword.

@return [Boolean] Returns true if the command complete successfully.
Shutdown semantics are opposite of enable semantics so invert enable.
cmd = "vrrp {vrid} shutdown"

set\_primary\_ip sets the primary IP address for the virtual router.

commands interface {no \| default} vrrp ip

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The primary IPv4 address.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the primary IP address using
the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} ip"

set\_priority sets the priority for a virtual router.

commands interface {no \| default} vrrp priority

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The priority value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the priority using the default
keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} priority"

set\_description sets the description for a virtual router.

commands interface {no \| default} vrrp description

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The description value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the description using the
default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} description"

build\_secondary\_ip\_cmd builds the array of commands required to
update the secondary IP addresses. This method allows the create methods
to leverage the code in the setter.

@api private

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param ip\_addrs [Array] Array of secondary IPv4 address. An empty array
will remove all secondary IPv4 addresses set for the virtual router on
the specified layer 3 interface.

@return [Array<String>] Returns the array of commands. The array could
be empty. Get the current secondary IP address set for the virtual
router A return of nil means that nothing has been configured for the
virtual router. Add commands to delete any secondary IP addresses that
are currently set for the virtual router but not in ip\_addrs. cmds <<
"no vrrp {vrid} ip {addr} secondary" Add commands to add any secondary
IP addresses that are not currently set for the virtual router but are
in ip\_addrs. cmds << "vrrp {vrid} ip {addr} secondary"
set\_secondary\_ips configures the set of secondary IP addresses
associated with the virtual router. The ip\_addrs value passed should be
an array of IP Addresses. This method will remove secondary IP addresses
that are currently set for the virtual router but not included in the
ip\_addrs array value passed in. The method will then add secondary IP
addresses that are not currently set for the virtual router but are
included in the ip\_addrs array value passed in.

commands interface {no} vrrp ip secondary

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param ip\_addrs [Array] Array of secondary IPv4 address. An empty array
will remove all secondary IPv4 addresses set for the virtual router on
the specified layer 3 interface.

@return [Boolean] Returns true if the command complete successfully.

set\_ip\_version sets the VRRP version for a virtual router.

commands interface {no \| default} vrrp ip version

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The VRRP version.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the VRRP version using the
default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} ip version"

set\_timers\_advertise sets the interval between successive
advertisement messages that the switch sends to routers in the specified
virtual router ID.

commands interface {no \| default} vrrp timers advertise

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The timer value in seconds.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the timer advertise value using
the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} timers advertise"

set\_mac\_addr\_adv\_interval sets the interval in seconds between
advertisement packets sent to VRRP group members for the specified
virtual router ID.

commands interface {no \| default} vrrp mac-address
advertisement-interval

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments

@option opts value [String] The mac address advertisement interval value
in seconds.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the timer advertise value using
the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} mac-address advertisement-interval"

set\_preempt sets the virtual router's preempt mode setting. When
preempt mode is enabled, if the switch has a higher priority it will
preempt the current master virtual router. When preempt mode is
disabled, the switch can become the master virtual router only when a
master virtual router is not present on the subnet, regardless of
priority settings.

commands interface {no \| default} vrrp preempt

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts enable [Boolean] If enable is true then the virtual router
preempt mode is administratively enabled for the interface and if enable
is false then the virtual router preempt mode is administratively
disabled for the interface. Default is true.

@option opts default [Boolean] Configure the timer advertise value using
the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} preempt"

set\_preempt\_delay\_min sets the minimum time in seconds for the
virtual router to wait before taking over the active role.

commands interface {no \| default} vrrp preempt delay minimum

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The preempt delay minimum value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the preempt delay minimum value
using the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} preempt delay minimum"

set\_preempt\_delay\_reload sets the preemption delay after a reload
only. This delay period applies only to the first interface-up event
after the virtual router has reloaded.

commands interface {no \| default} vrrp preempt delay reload

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments.

@option opts value [String] The preempt delay reload value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] :default Configure the preempt delay
reload value using the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} preempt delay reload"

set\_delay\_reload sets the delay between system reboot and VRRP
initialization for the virtual router.

commands interface {no \| default} vrrp delay reload

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param opts [hash] Optional keyword arguments

@option opts value [String] The delay reload value.

@option opts enable [Boolean] If false then the command is negated.
Default is true.

@option opts default [Boolean] Configure the delay reload value using
the default keyword.

@return [Boolean] Returns true if the command complete successfully. cmd
= "vrrp {vrid} delay reload"

build\_tracks\_cmd builds the array of commands required to update the
tracks. This method allows the create methods to leverage the code in
the setter.

@api private

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param tracks [Array] Array of a hash of track information. Hash format:
{ name: 'Eth2', action: 'decrement', amount: 33 }, The name and action
key are required. The amount key should only be specified if the action
is shutdown. The valid actions are 'decrement' and 'shutdown'. An empty
array will remove all tracks set for the virtual router on the specified
layer 3 interface.

@return [Array<String>] Returns the array of commands. The array could
be empty. Validate the track hash rubocop:disable Style/Next fail
ArgumentError, 'Key: {key} invalid in track hash' Get the current tracks
set for the virtual router. A return of nil means that nothing has been
configured for the virtual router. Add commands to delete any tracks
that are currently set for the virtual router but not in tracks. cmds <<
"no vrrp {vrid} track {tk[:name]} {tk[:action]}" Add commands to add any
tracks that are not currently set for the virtual router but are in
tracks. cmd = "vrrp {vrid} track {tk[:name]} {tk[:action]}" cmd << "
{tk[:amount]}" if tk.key?(:amount) set\_tracks configures the set of
track settings associated with the virtual router. The tracks value
passed should be an array of hashes, each hash containing a track entry.
This method will remove tracks that are currently set for the virtual
router but not included in the tracks array value passed in. The method
will then add tracks that are not currently set for the virtual router
but are included in the tracks array value passed in.

commands interface {no} vrrp track []

@param name [String] The layer 3 interface name.

@param vrid [Integer] The virtual router ID.

@param tracks [Array] Array of a hash of track information. Hash format:
{ name: 'Eth2', action: 'decrement', amount: 33 }, An empty array will
remove all tracks set for the virtual router on the specified layer 3
interface.

@return [Boolean] Returns true if the command complete successfully.
