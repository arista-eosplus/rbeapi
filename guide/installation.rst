Installation
============

.. contents:: :local:

The source code for rbeapi is provided on Github at
http://github.com/arista-eosplus/rbeapi. All current development is done in the
develop branch. Stable released versions are tagged in the master branch and
uploaded to RubyGems.

To install the latest stable version of rbeapi, simply run ``gem install
rbeapi``

To install the latest development version from Github, simply clone the develop
branch and run

.. code-block:: console

    $ rake build
    $ rake install

    To create an RPM, run ``rake rpm``

    To generate a SWIX file for EOS with necessary dependencies, run ``rake
    all_rpms`` then follow the swix create instructions, provided by the build.
    NOTE: Puppet provides a puppet agent SWIX which includes Ruby 1.9.3 in
    /opt/puppetlabs/bin/ which is different from where you might otherwise
    install Ruby. If you have installed the puppet-enterprise 3.x SWIX, then
    you should build and use the rbeapi-puppet3 swix, below. If you have
    installed the puppet-enterprise 2015.x SWIX, then you should build and use
    the rbeapi-puppet-aio swix, below. The Chef client omnibus install also
    includes its own version of Ruby in /opt/chef/bin/, thus the rbeapi-chef
    swix should be used.  Otherwise, if you have installed at least Ruby
    1.9.3 in the standard system location, then the rbeapi SWIX may be used.

.. code-block:: console

    $ bundle install --path .bundle/gems/
    $ bundle exec rake all_rpms
    ...
    RPMs are available in rpms/noarch/
    Copy the RPMs to an EOS device then run the 'swix create' command.
    Examples: 
      Puppet Open Source: 
        cd /mnt/flash; \
        swix create rbeapi-0.4.0-1.swix \
        rubygem-rbeapi-0.4.0-1.eos4.noarch.rpm \
        rubygem-inifile-3.0.0-3.eos4.noarch.rpm \
        rubygem-netaddr-1.5.0-2.eos4.noarch.rpm \
        rubygem-net_http_unix-0.2.1-3.eos4.noarch.rpm
      Puppet-enterprise agent (3.x): 
        cd/mnt/flash; \
        swix create rbeapi-puppet3-0.4.0-1.swix \
        rubygem-rbeapi-puppet3-0.4.0-1.eos4.noarch.rpm \
        rubygem-inifile-puppet3-3.0.0-3.eos4.noarch.rpm \
        rubygem-netaddr-puppet3-1.5.0-2.eos4.noarch.rpm
      Puppet-All-in-one agent (2015.x/4.x): 
        cd/mnt/flash; \
        swix create rbeapi-puppet-aio-0.4.0-1.swix \
        rubygem-rbeapi-puppet-aio-0.4.0-1.eos4.noarch.rpm \
        rubygem-inifile-puppet-aio-3.0.0-3.eos4.noarch.rpm \
        rubygem-netaddr-puppet-aio-1.5.0-2.eos4.noarch.rpm \
        rubygem-net_http_unix-puppet-aio-0.2.1-3.eos4.noarch.rpm

On EOS:

.. code-block:: console

    Arista# copy <URI-to-RPMs> flash:
    Arista# bash
    -bash-4.1# cd /mnt/flash/
    -bash-4.1# swix create rbeapi-puppet3-0.4.0-1.swix \
               rubygem-rbeapi-puppet3-0.4.0-1.eos4.noarch.rpm \
               rubygem-inifile-puppet3-3.0.0-1.eos4.noarch.rpm \
               rubygem-netaddr-puppet3-1.5.0-1.eos4.noarch.rpm
    -bash-4.1# exit
    Arista# copy flash:rbeapi-puppet3-0.4.0-1.swix extension:
    Arista# extension rbeapi-puppet3-0.4.0-1.swix
    Arista# copy installed-extensions boot-extensions

