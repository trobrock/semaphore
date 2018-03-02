module Semaphore
  class Lock
    POLLING_INTERVAL = 0.2.freeze
    attr_reader :name

    def initialize(name, store: nil)
      @name = name

      @backend = store || Stores::MemoryStore.new
    end

    def lock(wait_for: nil)
      poll_for_status(wait_for)
    end

    def unlock
      @backend.unlock!
    end

    private

    def poll_for_status(wait_for)
      now = Time.now

      loop do
        if @backend.locked?
          break unless wait_for && continue_polling?(wait_for, now)
          sleep POLLING_INTERVAL
        else
          @backend.lock!
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
