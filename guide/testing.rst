Testing Modules
===============

.. contents:: :local:

The rbeapi library provides spec tests. To run the spec tests, you will need to
update the `spec/fixtures/dut.conf` file. The switch used for testing
must have at least interfaces Ethernet1-7.

To run the spec tests, run `bundle exec rspec spec` from the root of the
rbeapi source folder.
