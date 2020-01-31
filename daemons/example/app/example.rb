# Example class demonstrating what is possible with the MCP v2 framework.

class Example < ::MCP::Daemon
    require_component :DB, :SCHEDULER

    # Declare persistent state variables.  These translate to keys in the
    # SystemState table, and accessors for them are automatically defined with
    # the prefix "last_".
    declare_state :some_saved_value, :another_saved_value

    # *Optional* hook to post-process any configuration directives present in
    # the daemon's configuration YAML.  The configuration is automatically
    # loaded by the Daemon subsystem and is available during runtime through
    # helpers: config, and daemon.config.
    #
    # There's a small twist: if the hook ever returns !!false, then the
    # particular key/value pair will not be committed to the configuration.  So,
    # this also represents an opportunity to non-fatally "filter" the config.
    #
    # TODO: establish whether everything passed through here includes app.yml,
    # in addition to <daemon>.yml.  I think it probably should.
    configure do |key, value|
        $LOG.warn "configure: #{key.inspect} => #{value.inspect}"
    end

    # *Optional* hook to capture any commandline options not already consumed by
    # the base Daemon class.
    #
    # Called *after* all available config file key/values have been given to the
    # configure hook, but *before* valid_config? is called.
    #
    # As this is mainly intended for configuration overrides, they should
    # generally map to configure() directives in order to maintain parity.
    # Regardless of the intent, there are *no* restrictions on how it can be
    # used.
    #
    # NOTE: Options: -w, -d and -h are reserved, but there doesn't appear to be
    # a way to enforce it, so keep it in mind.
    cmdline_arguments do |opts|
        opts.on('-D', '--demo', 'Demo option') do
            $LOG.info 'Demo command line option'
            configure({:demo_option=>"true"})
        end
    end

    # *Optional* "am I good to go?" configuration check, after all available
    # config file key/values have been given to the configure hook.  If this
    # method is not defined, no validation is done.
    #
    # If this returns false, the daemon will refuse to boot and exit. This
    # avoids the unicorn "cycling" problem of attempting to start, failing,
    # re-attempting, failing, etc.
    def valid_config?
        $LOG.warn "config validation"
        return true
    end

    # *Optional* hook to run code before any of the components (AMQP, Scheduler,
    # DB) are initialized.
    before :init do
        $LOG.warn "before init"
    end

    # *Optional* hook to run code after the Daemon spawns us or Launcher forks
    # us, just before we enter into a blocking run loop.
    after :spawn do
        $LOG.warn "after spawn"
    end

end

class Schedule
    # Only public methods in the Schedule class are automatically registered
    # with the Scheduler.  Non-public (protected, private) will be ignored.
    #
    # NOTE: Scheduled methods are responsible for re-scheduling themselves.
    #
    # Helper Methods
    #
    #   (1) daemon - accessor for class instance encapsulating your Schedule
    #   (2) config - accessor for daemon-specific configuration (used below)
    #
    #   The daemon instance itself has accessors you might find useful:
    #
    #     (1) daemon.schedule - instance of Schedule (if enabled)
    #     (3) daemon.config   - the config helper above just maps to this

    def do_something
        $LOG.debug "Do something here"
        sleep 1
    ensure
        # Reschedule ourselves.
        @do_something_interval ||= config[:do_something] || 3.seconds
        $SCHEDULER.in(@do_something_interval, :do_something)
    end

    protected

    # Example non-public method that won't be registered with the Scheduler.
    # Can be class or instance methods, though class methods will need to be
    # accessed with "self.class.the_method".
    def some_helper_method
        puts "helper called"
        return "some info"
    end

    # NOTE: You don't typically need this method.  But because we're an
    # example, we want the scheduler to run faster than normal.  This
    # mechanism is here to let you modify the Scheduler instance before
    # booting, if necessary.
    def configure(scheduler)
        scheduler.interval = 1.second
    end
end
