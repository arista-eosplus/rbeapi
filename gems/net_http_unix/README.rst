This directory contains packaging information to create a basic RPM of
the net_http_unix ruby gem for EOS.  Due to thenature of EOS, certain shortcuts
were used instead of the more formal method:

    gem2rpm --fetch net_http_unix > net_http_unix.spec
