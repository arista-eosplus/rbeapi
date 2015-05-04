This directory contains packaging information to create a basic RPM of
the inifile ruby gem for EOS.  Due to thenature of EOS, certain shortcuts
were used instead of the more formal method:

    gem2rpm --fetch inifile > inifile.spec
