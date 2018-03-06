module Semaphore
  module Stores
    class MemoryStore
      attr_reader :name, :expires_at

      def initialize(name)
        @name = name
      end

      def locked?
        if @locked && @expires_at && Time.now >= @expires_at
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
    end
  end
end
