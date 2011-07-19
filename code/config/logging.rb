
Logging.format_as :inspect
layout = Logging.layouts.pattern(:pattern => '[%d] %-5l %c : %m\n')

Logging.appenders.stdout(
  'stdout',
  :auto_flushing => true,
  :layout => layout
) if config.log_to.include? 'stdout'

Logging.appenders.rolling_file(
  'logfile',
  :filename => File.join(config.log_path,"#{config.app_name}.#{config.environment}.log"),
  :keep => 7,
  :age => 'daily',
  :truncate => false,
  :auto_flushing => config.log_auto_flushing,
  :layout => layout
) if config.log_to.include? 'logfile'

Logging.appenders.email(
  'email',
  :from     => "#{config.app_name}@example.com",
  :to       => 'help@example.com',
  :server   => 'smtp.example.com',
  :domain   => 'example.com',
  :acct     => 'you@example.com',
  :passwd   => '1234',
  :subject  => "#{config.app_name.capitalize} App Error",
  :authtype => :login,
  :auto_flushing => true,
  :layout        => layout,
  :level         => :error
) if config.log_to.include? 'email'

Logging.logger.root.level = config.log_level
Logging.logger.root.appenders = config.log_to unless config.log_to.empty?

