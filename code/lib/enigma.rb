
unless defined? Enigma

require 'logging'
require 'loquacious'
require 'servolux'
require 'beanstalk-client'

include Logging.globally

module Enigma

  # :stopdoc:
  LIBPATH = ::File.expand_path('../', __FILE__) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns a help object that can be used to show the current Enigma
  # configuration and descriptions for the various configuration attributes.
  #
  def self.help
    Loquacious.help_for('Enigma', :colorize => config.colorize, :nesting_nodes => false)
  end

  # Returns the Enigma configuration object. If a block is given, then it will
  # be evaluated in the context of the configuration object.
  #
  def self.config( &block )
    Loquacious.configuration_for('Enigma', &block)
  end

  # Set the default properties for the Enigma configuration. A _block_ must
  # be provided to this method.
  #
  def self.defaults( &block )
    Loquacious.remove :gem, :main, :timeout, :delay
    Loquacious.defaults_for('Enigma', &block)
  end

  # Returns the configuration path for the Enigma framework. This configuration
  # path is the location where database and environment specific settings are
  # located. Actually, it is an array of paths that will be searched in order
  # for the various configuration files.
  #
  # The configuration path is configured using the Enigma config block.
  #
  #   Enigma.config {
  #     config_path ['foo/bar/baz']
  #   }
  #
  # The default configuration path is the "config" directoy located alongside
  # the Enigma "lib" folder.
  #
  def self.config_path( *args )
    config = Enigma.config
    if args.empty?
      config.config_path.each {|path| return path if test ?e, path}
      return config.config_path.first
    end

    args.flatten!
    config.config_path.each do |path|
      p = File.join(path, args)
      return p if test ?e, p
    end
    return File.join(config.config_path.first, args)
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  libpath {
    require 'enigma/config'
    require 'enigma/initializer'
    require 'enigma/app'
  }
end

end  # unless defined?
