
module Enigma

  # The Enigma application connects to a beanstalkd job queue and waits for
  # enigma decode jobs to become available. Each job is processed in order,
  # and the decoded text is written to a file in the "config.decode_folder".
  #
  class App < Servolux::Server

    # Create a new Enigma application server.
    #
    def initialize
      super(Enigma.config.app_name,
          :logger   => Logging.logger[self],
          :pid_file => Enigma.config.pid_file
      )
      @job = nil
      @beanstalk = nil
      @folder = Enigma.config.decode_folder
      FileUtils.mkdir_p @folder
    end

    # Before the enigma run loop starts, open a connection to the beanstalk
    # job queue.
    #
    def before_starting
      config = Enigma.config.beanstalk
      @beanstalk = Beanstalk::Pool.new "#{config.host}:#{config.port}"
    end

    # After enigma has started, log a message to let the user know that
    # everything is up and running.
    #
    def after_starting
      logger.info 'Running'
    end

    # In order to shutdown in a timely fashion, we need to close our
    # connection to the beanstalk job queue.
    #
    def before_stopping
      return unless @beanstalk
      @beanstalk, beanstalk = nil, @beanstalk

      beanstalk.close if @job.nil?
      Thread.pass  # allow the server thread to wind down
    end

    # After enigma has stopped, log a message to let the user know that
    # everything has shutdown.
    #
    def after_stopping
      logger.info 'Stopped'
    end

    # The main enigma run loop. This will grab a job from the beanstalk queue,
    # process the message, and store the decrypted results.
    #
    def run
      logger.debug 'Entering main run loop'
      return unless @beanstalk

      @job = @beanstalk.reserve 30 rescue nil
      if @job
        logger.info "Processing '#{@job.id}'"
        decoded = Base64.decode64(@job.body)
        File.open("#{@folder}/#{@job.id}.txt",'w') { |fd| fd.write decoded }
      end

    # raised when the beanstalk.reserve timeout is reached - ignore and continue processing
    rescue Beanstalk::TimedOut

    # log all errors and continue processing
    rescue StandardError => err
      logger.info "Error while processing job '#{@job ? @job.id : 'nil'}'"
      logger.error err
    ensure
      @job.delete rescue nil if @job
      @job = nil
    end

    # If SIGUSR1 is sent to the process, then the logging level is
    # toggled between the normal level and the debug level.
    #
    def usr1
      @__level ||= nil
      r = Logging.logger.root

      if @__level.nil?
        r.level, @__level = :debug, r.level
        logger.debug "Entering debug mode."
      else
        logger.debug "Exiting debug mode."
        r.level, @__level = @__level, nil
      end
    end

    # If SIGHUP is sent to the process, then the configuration will be updated
    # by parsing the files again.
    #
    def hup
      Enigma.setup.load_environment
    end

  end  # class App
end  # module Enigma

