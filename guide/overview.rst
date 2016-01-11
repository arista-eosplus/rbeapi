Overview
========

.. contents:: :local:

Introduction
------------

The Ruby Client for eAPI provides a native Ruby implementation for programming Arista EOS network devices using Ruby.  The Ruby client provides the ability to build native applications in Ruby that can communicate with EOS either locally via Unix domain sockets (on-box) or remotely over a HTTP/S transport (off-box).  It uses a standard INI-style configuration file to specifiy one or more connection profiles.

The rbeapi implemenation also provides an API layer for building native Ruby objects that allow for configuration and state extraction of EOS nodes.  The API layer provides a consistent implementation for working with EOS configuration resources.  The implementation of the API layer is highly extensible and can be used as a foundation for building custom data models.

The libray is freely provided to the open source community for building robust applications using Arista EOS eAPI.  Support is provided as best effort through Github iusses.

Prerequisites
-------------

* Arista EOS 4.12 or later
* Arista eAPI enabled for at least one transport (see official EOS Config Guide at arista.com for details)
* Ruby 1.9.3 or later