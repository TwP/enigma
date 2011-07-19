
module Enigma
  # Run the Enigma initialization process. If a block is given to this method,
  # the Enigma configuration object will be yielded to the block after the
  # environment has been loaded. This allows the user to override
  # enironmental configuration settings at runtime.
  #
  def self.setup( &block )
    return @__initializer if defined? :@__initializer and @__initializer
    @__initializer = Enigma::Initializer.run(&block)
  end

  # The initializer configures the Enigma framework according to the user
  # specified settings. The various initialization steps can be reorderd or
  # skipped altogether if that is the desire. Environment specific
  # configurations and heirerarchical configuration paths are supported.
  #
  class Initializer

    # Create a new Initializer instance and run the initialization process. If
    # a block is given to this method, the Enigma configuration object will be
    # yielded to the block after the environment has been loaded. This allows
    # the user to override enironmental configuration settings at runtime.
    #
    def self.run( *args, &block )
      new.process(*args, &block)
    end

    # Create a new Initializer instance.
    #
    def initialize
      @config = Enigma.config
    end

    # Run the initialization process. If a block is given to this method,
    # the Enigma configuration object will be yielded to the block after the
    # environment has been loaded. This allows the user to override
    # enironmental configuration settings at runtime.
    #
    def process( *args, &block )
      load_environment
      block.call(@config) unless block.nil?
      @config.initializers.each {|init| self.send "initialize_#{init}"}
      self
    end

    # Load environment specific configuration settings if the environment file
    # exists.
    #
    def load_environment
      fn = Enigma.config_path('environments', "#{@config.environment}.rb")
      return self unless test(?f, fn)

      config = @config
      eval(IO.read(fn), binding, fn)
      self
    end

    # Setup the logging framework.
    #
    def initialize_logging
      fn = Enigma.config_path('logging.rb')
      return self unless test(?f, fn)

      if @config.log_path and !test(?e, @config.log_path)
        FileUtils.mkdir @config.log_path
      end

      config = @config
      eval(IO.read(fn), binding, fn)

      Logging.show_configuration if Logging.logger[Enigma].debug?
      self
    end

  end  # Initializer
end  # module Enigma
