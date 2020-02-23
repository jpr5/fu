# Example: $SCHEDULER.at(Time.now + 60.minutes, expire_task, [1234123])
#
module FU::Scheduler
    include ::Singleton

    const_def :DEFAULT_INTERVAL, 60.seconds # seconds

    attr_accessor :interval, :mutex, :thread, :schedule, :last_id, :delegate;

    extend Enumerable

    def initialize
        self.interval = DEFAULT_INTERVAL
        self.schedule = {} # { id => { :time => x, :proc => &proc, :params => [] } }
        self.mutex    = Mutex.new
        self.thread   = nil
        self.last_id  = 0
    end

    def boot!(async = true)
        shutdown!

        if $CONFIG[:scheduler].among?(0, false, "0", "false", "off", "disable", "disabled")
            $LOG.debug "scheduler: disabled"
            return
        end

        self.schedule = (self.delegate || Schedule.new)
        self.schedule.send(:configure, self) if self.schedule.respond_to?(:configure)

        $LOG.debug "scheduler: booting"

        # Look at configuration to automatically populate recurring jobs
        $CONFIG[:schedule]&.each do |job_sym, interval|
            unless job = schedule.method(job_sym)
                $LOG.error "scheduler: unknown job '#{job_sym}', skipping"
                next
            end

            self.schedule_job(job, interval, recur: true)
        end

        self.thread = Thread.new { self.run! }
        self.thread.join unless async
    end

    def shutdown!
        if self.thread
            $LOG.debug "scheduler: shutting down"
            self.thread.kill.join
            self.thread = nil
        end
    end

    def block!
        self.thread.join
    end

    def run!
        loop do
            # Check if the proc is past-due (due_in is negative).  If not,
            # record the smallest interval from the entire schedule for which
            # we'll sleep until we run again.
            next_interval = self.interval

            # Lock the schedule and run a copy of it, by iteratively removing
            # each job from the copy as we go, and rescheduling those that are
            # configured to recur.
            mutex.synchronize do
                $LOG.debug "scheduler: scanning #{schedule.length}"
                now = Time.now

                schedule.dup.each do |id, h|
                    overdue = now > h[:at]
                    unless overdue
                        next_interval = [next_interval, h[:at] - now].min
                        next
                    end

                    Thread.new do
                        begin
                            # Remove from main schedule ASAP, *then* do work.
                            $SCHEDULER.remove(id)
                            h[:proc].call(*h[:params])
                        rescue Exception => e
                            $LOG.error(e) { "scheduler: #{h[:proc]} (#{id}) raised exception" }
                        ensure
                            # Reschedule this job if configured to recur.
                            if h[:recur] and $CONFIG[:schedule] and interval = $CONFIG[:schedule][h[:proc]]
                                self.schedule_job(h[:proc], interval, recur: true)
                            end
                        end
                    end
                end
            end

            sleep(next_interval.ceil)
        end
    end

    def clear!
        mutex.synchronize { schedule.clear }
    end

    def remove(id)
        mutex.synchronize { schedule.delete(id) }
    end

    def asap(params = [], &proc)
        return self.in(0, params, &proc)
    end

    def in(timediff, params = [], recur: false, &proc)
        return at(timediff.from_now, params, recur: recur, &proc)
    end

    def at(time, params = [], recur: false, &proc)
        id = last_id

        mutex.synchronize do
            id = next_id while schedule[id]

            schedule[id] = {
                id:     id,
                at:     time,
                proc:   proc,
                params: params,
                recur:  recur, # Indicate if this job is a recurring a job
            }
        end

        return id
    end

    def each
        mutex.synchronize do
            schedule.each_value { |todo| yield todo }
        end
    end

    private

    def schedule_job(job, interval, recur: true)
        delay_type, delay = parse_interval(interval)

        if delay_type == :at
            self.at(delay, job, [], recur)
            $LOG.debug "schedule: job #{job} running at #{interval}, next at #{delay} (recur: #{recur})"
        elsif delay_type == :in
            self.in(delay, job, [], recur)
            $LOG.info "schedule: job #{job} running on interval #{delay}s (recur: #{recur})"
        else
            raise "unknown delay_type #{delay_type}"
        end
    end

    # Interpret interval configuration
    def parse_interval(interval)
        # interval is an integer, that means the interval should be interval seconds from now
        return [:in, interval] if interval.is_a?(Integer)

        if interval.is_a?(String)
            # interval is a string, that specify particular time to run this
            next_time = Time.parse(interval)
            now = Time.now
            while next_time.to_i < now.to_i
                next_time += 1.day
            end
            return [:at, next_time]
        end

        # if not a hash, interpret as strictly interval seconds
        unless interval.is_a?(Hash)
            raise "unknown interval type #{interval.class}"
        end

        # if no strategy is specified, assume it is strict
        return interval unless strategy = interval[:strategy]

        strategy_klass_name = strategy.to_s.capitalize

        unless strategy_klass = Strategy.const_get(strategy_klass_name)
            raise "Unknow scheduler strategy: #{strategy_klass_name}, check your app config"
        end

        real_strategy = strategy_klass.new(interval)
        return [:in, real_strategy.subsequent]
    end

    def next_id
        self.last_id += 1
    end

    module Strategy

        # Scheduling strategies return a number of seconds before the first
        # scheduled action (initial), and after that they get asked for a
        # subsequent period to wait each time the scheduled thing is run.

        class Jittered
            def initialize(config)
                @interval   = config[:interval]
                @range      = config[:jittered]
            end

            def initial
                initial = rand(@interval)
                $LOG.debug("First scheduled run in #{initial}s")
                return initial
            end

            def subsequent
                return jittered
            end

            def jittered
                jitter = (1.0 - (rand * 2.0)) * @interval * @range

                return (@interval + jitter).round
            end
        end
    end

end

$SCHEDULER = ::FU::Scheduler.instance
#$SCHEDULER.send(:include, ::FU::Scheduler::Exceptions)
