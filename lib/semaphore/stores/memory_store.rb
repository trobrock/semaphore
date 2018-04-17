module Semaphore
  module Stores
    class MemoryStore
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def locked?
        if expired?
          unlock!
          false
        else
          !!@locked
        end
      end

      def lock!(expires_in: nil)
        @locked = true
        @expires_at = Time.now + expires_in if expires_in
        true
      end

      def unlock!
        @locked = false
        @expires_at = nil
        true
      end

      def expired?
        @locked && @expires_at && Time.now >= @expires_at
      end
    end
  end
end
