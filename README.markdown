Logging
=======

Enigma is part of a presentaion for the local Boulder Ruby Users Gruop. It is
an example of integrating several Ruby gems into a coherent whole in order to
create a basic ruby service.

The concept driving the presentation is that we need to take a simple "enigma"
decoder script and convert it into a full Ruby application complete with
daemonization, logging, configuration, command line parsing, etc. Our "enigma"
algorithm is simply the Base64.decode method that comes as part of the Ruby
standard library.

The codebase here is fully functional although lean in the areas of
robustnuess and error handling. That is left as an exercise for the reader.

Setup
-----

If you wish to run the code example, then you will need to install the
following Ruby gems:

  beanstalk-client
  logging
  loquacious
  main
  servolux

There is a script in the "code" folder called "setup.sh" that will install
these gems for you.

Running
-------

The enigma command is provided in the "bin" folder of the code area. And since
this whole presentation is about using built in tools, please use the "--help"
option to figure out how to use the software.

  bin/enigma --help


Thanks for reading!
TwP
