module Semaphore
  class Lock
    POLLING_INTERVAL = 0.2.freeze
    attr_reader :name

    def initialize(name, store: nil)
      @name = name

      @backend = (store || Stores::MemoryStore).new(name)
    end

    def lock(wait_for: nil, before_wait: nil, expires_in: nil)
      poll_for_status(wait_for: wait_for, before_wait: before_wait, expires_in: expires_in)
    end

    def unlock
      @backend.unlock!
    end

    private

    def poll_for_status(wait_for: nil, before_wait: nil, expires_in: nil)
      now = Time.now

      loop do
        if @backend.locked?
          break unless wait_for && continue_polling?(wait_for, now)
          before_wait.call if before_wait
          sleep POLLING_INTERVAL
        else
          @backend.lock!(expires_in: expires_in)
          return true
        end
      end

      false
    end

    def continue_polling?(wait_for, started_at)
      wait_for.is_a?(Numeric) ? Time.now - started_at < wait_for : true
    end
  end
end
