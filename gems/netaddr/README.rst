This directory contains packaging information to create a basic RPM of
the netaddr ruby gem for EOS.  Due to thenature of EOS, certain shortcuts
were used instead of the more formal method:

    gem2rpm --fetch netaddr > netaddr.spec.tmpl
