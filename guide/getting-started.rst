Getting Started
===============

.. contents:: :local:

In order to use rbeapi, the EOS command API must be enabled using management api http-commands configuration mode. This library supports eAPI calls over both HTTP and UNIX Domain Sockets. Once the command API is enabled on the destination node, create a configuration file with the node properities.

Note: The default search path for the conf file is ~/.eapi.conf followed by /mnt/flash/eapi.conf. This can be overridden by setting EAPI_CONF=<path file conf file> in your environment.

Example eapi.conf File
----------------------

Below is an example of an eAPI conf file. The conf file can contain more than one node. Each node section must be prefaced by connection:<name> where <name> is the name of the connection.

The following configuration options are available for defining node entries:

    host - The IP address or FQDN of the remote device. If the host parameter is omitted then the connection name is used
    username - The eAPI username to use for authentication (only required for http or https connections)
    password - The eAPI password to use for authentication (only required for http or https connections)
    enablepwd - The enable mode password if required by the destination node
    transport - Configures the type of transport connection to use. The default value is https. Valid values are:
        socket (available in EOS 4.14.5 or later)
        http_local (available in EOS 4.14.5 or later)
        http
        https
    port - Configures the port to use for the eAPI connection. A default port is used if this parameter is absent, based on the transport setting using the following values:
        transport: http, default port: 80
        transport: https, deafult port: 443
        transport: https_local, default port: 8080
        transport: socket, default port: n/a
    open_timeout - The default number of seconds to wait for the eAPI connection to open. Any number may be used, including Floats for fractional seconds. Default value is 10 seconds.
    read_timeout - The default number of seconds to wait for one block of eAPI results to be read (via one read(2) call). Any number may be used, including Floats for fractional seconds. Default value is 10 seconds.

Note: See the EOS User Manual found at arista.com for more details on configuring eAPI values.

All configuration values are optional.

[connection:veos01]
username: eapi
password: password
transport: http

[connection:veos02]
transport: http

[connection:veos03]
transport: socket

[connection:veos04]
host: 172.16.10.1
username: eapi
password: password
enablepwd: itsasecret
port: 1234
transport: https

[connection:localhost]
transport: http_local

The above example shows different ways to define EOS node connections. All configuration options will attempt to use default values if not explicitly defined. If the host parameter is not set for a given entry, then the connection name will be used as the host address.

Configuring [connection:localhost]
----------------------------------

The rbeapi library automatically installs a single default configuration entry for connecting to localhost host using a transport of sockets. If using the rbeapi library locally on an EOS node, simply enable the command API to use sockets and no further configuration is needed for rbeapi to function. If you specify an entry in a conf file with the name [connection:localhost], the values in the conf file will overwrite the default.

Using rbeapi
------------

The Ruby Client for eAPI was designed to be easy to use and implement for writing tools and applications that interface with the Arista EOS management plane.

Creating a connection and sending commands
------------------------------------------

Once EOS is configured properly and the config file created, getting started with a connection to EOS is simple. Below demonstrates a basic connection using rbeapi. For more examples, please see the examples folder.

# start by importing the library
require 'rbeapi/client'

# create a node object by specifying the node to work with
node = Rbeapi::Client.connect_to('veos01')

# send one or more commands to the node
node.enable('show hostname')
node.enable('show hostname')
=> [{:command=>"show hostname", :result=>{"fqdn"=>"veos01.arista.com", "hostname"=>"veos01"}, :encoding=>"json"}]

# use the config method to send configuration commands
node.config('hostname veos01')
=> [{}]

# multiple commands can be sent by using a list (works for both enable or config)

node.config(['interface Ethernet1', 'description foo'])
=> [{}, {}]

# return the running or startup configuration from the node (output omitted for brevity)

node.running_config

node.startup_config

Using the API
-------------

The rbeapi library provides both a client for send and receiving commands over eAPI as well as an API for working directly with EOS resources. The API is designed to be easy and straightforward to use yet also extensible. Below is an example of working with the vlans API

# create a connection to the node
require 'rbeapi/client'
node = Rbeapi::Client.connect_to('veos01')

# get the instance of the API (in this case vlans)
vlans = node.api('vlans')

# return all vlans from the node
vlans.getall
=> {"1"=>{:name=>"tester", :state=>"active", :trunk_groups=>[]},
 "4"=>{:name=>"VLAN0004", :state=>"active", :trunk_groups=>[]},
 "100"=>{:name=>"TEST_VLAN_100", :state=>"active", :trunk_groups=>[]},
 "300"=>{:name=>"VLAN0300", :state=>"active", :trunk_groups=>[]}}

# return a specific vlan from the node
vlans.get(1)
=> {:name=>"tester", :state=>"active", :trunk_groups=>[]}

# add a new vlan to the node
vlans.create(400)
=> true

# set the new vlan name
vlans.set_name(100, value: 'foo')
=> true

All API implementations developed by Arista EOS+ CS are found in the rbeapi/api folder. See the examples folder for additional examples.