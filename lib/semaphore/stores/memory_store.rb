module Semaphore
  module Stores
    class MemoryStore
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def locked?
        !!@locked
      end

      def lock!
        @locked = true
      end

      def unlock!
        @locked = false
        true
      end
    end
  end
end
