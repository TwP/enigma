
# grab a copy of the config object for use in Proc objects below
config = Enigma.config {}

# setup the default Enigma configuration
Enigma.defaults {
  app_name  $0.dup, :desc => <<-__
    Name of the running program (used for log file naming).
  __

  desc <<-__
    The name and location of the PID file. This file is used to output the
    process ID of an Enigma application when started as a daemon.
  __
  pid_file(Proc.new {
    File.join(config.log_path, "#{config.app_name}.#{config.environment}.pid")
  })

  initializers  %w[logging], :desc => <<-__
    Array of initializers to run when the system is initialized.
  __

  config_path ['config', '/etc/engima', Enigma.path('config')], :desc => <<-__
    Path where configuration and environment files can be found.
  __

  environment :development, :desc => <<-__
      The current runtime environment. Can be one of
      |
      |  :production
      |  :development
      |  :test
      |
  __

  log_path 'log', :desc => <<-__
    Path where log files will be written.
  __

  log_level :info, :desc => <<-__
    The default logging level for the system.
  __

  log_to %w[logfile], :desc => <<-__
    An array of logging destinations.
  __

  log_auto_flushing true, :desc => <<-__
    Determines where the logging destinations will buffer messages or
    flush after every log message.
  __

  colorize true, :desc => <<-__
    When set to "true" colorization will be applied to the output of the
    configuration parameters. This setting supports calls to the 'Enigma.help'
    method.
  __

  desc <<-__
    Decoded messages will be written to this folder. Messages are identified
    by their beanstalk 'job.id' number.
  __
  decode_folder(Proc.new {
    File.join('decode', config.environment.to_s)
  })

  desc 'Container for the beanstalk configuration'
  beanstalk {
    host 'localhost', :desc => 'The host where the beanstalkd server can be reached'
    port 11300,       :desc => 'The port number where the beanstalkd server can be reached'
  }

}

