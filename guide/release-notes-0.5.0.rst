Release 0.5.0 - January 2016
----------------------------

.. contents:: :local:

Enhancements
^^^^^^^^^^^^

* Add lacp_mode option when setting port-channel members. (`89 <https://github.com/arista-eosplus/rbeapi/pull/89>`_) [`devrobo <https://github.com/devrobo>`_]
    .. comment
* Add support for trunk groups. (`88 <https://github.com/arista-eosplus/rbeapi/pull/88>`_) [`devrobo <https://github.com/devrobo>`_]
    .. comment
* Unit tests for switchports (`94 <https://github.com/arista-eosplus/rbeapi/pull/94>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment
* Ensure all parse methods are private. (`93 <https://github.com/arista-eosplus/rbeapi/pull/93>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment
* Add tests for timeout values (`92 <https://github.com/arista-eosplus/rbeapi/pull/92>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment
* Relax check on getall entries (`91 <https://github.com/arista-eosplus/rbeapi/pull/91>`_) [`devrobo <https://github.com/devrobo>`_]
    .. comment
* Update framework tests (`90 <https://github.com/arista-eosplus/rbeapi/pull/90>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment
* Add basic framework tests. (`85 <https://github.com/arista-eosplus/rbeapi/pull/85>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment
* Address code coverage gaps (`84 <https://github.com/arista-eosplus/rbeapi/pull/84>`_) [`websitescenes <https://github.com/websitescenes>`_]
    .. comment

Fixed
^^^^^

* Copy configuration entry before modifying with connection specific info. (`101 <https://github.com/arista-eosplus/rbeapi/pull/101>`_)
    .. comment
* Add 'terminal' to configure command to work around AAA issue. (`99 <https://github.com/arista-eosplus/rbeapi/pull/99>`_)
    .. comment
* Set enable password for a connection. (`96 <https://github.com/arista-eosplus/rbeapi/pull/96>`_)
    .. comment
* Catch errors and syslog them when parsing eapi conf file. (`95 <https://github.com/arista-eosplus/rbeapi/pull/95>`_)
    In the event of an unparsable ``eapi.conf`` file, which could occur due to other tools which used a YAML syntax instead of INI, rbeapi will log a warning via syslog, but continue to attempt a default connection to localhost.
    .. comment
* Ensure that nil is returned when getting nonexistent username. (`83 <https://github.com/arista-eosplus/rbeapi/pull/83>`_)
    .. comment
* Failure when eapi.conf is not formatted correctly (`82 <https://github.com/arista-eosplus/rbeapi/issues/82>`_)
    In the event of an unparsable ``eapi.conf`` file, which could occur due to other tools which used a YAML syntax instead of INI, rbeapi will log a warning via syslog, but continue to attempt a default connection to localhost.
* Enable password setting in the .eapi.conf file not honored (`72 <https://github.com/arista-eosplus/rbeapi/issues/72>`_)
    ``enablepwd`` is now properly used, if defined, in the ``eapi.conf``
* API interfaces should accept an lacp_mode to configure for port-channel members (`58 <https://github.com/arista-eosplus/rbeapi/issues/58>`_)
    ``set_members()`` now configures LACP mode when adding members to a port-channel

Known Caveats
^^^^^^^^^^^^^

* Add support for commands with input (`100 <https://github.com/arista-eosplus/rbeapi/issues/100>`_)
    .. comment
* Wildcard connection config gets clobbered (`86 <https://github.com/arista-eosplus/rbeapi/issues/86>`_)
    .. comment
* Need to validate value keyword in set methods when array (`40 <https://github.com/arista-eosplus/rbeapi/issues/40>`_)
    .. comment
* get_connect should raise an error instead of returning nil if no connection is found (`31 <https://github.com/arista-eosplus/rbeapi/issues/31>`_)
    .. comment

