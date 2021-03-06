require 'aws-sdk'

module Semaphore
  module Stores
    class DynamodbStore
      TABLE_NAME = 'semaphore-dynamodb'.freeze

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def locked?
        if expired?
          unlock!
          false
        else
          !!item
        end
      end

      def lock!(expires_in: nil)
        data = { id: @name, created: Time.now.to_i }
        data[:expires_at] = (Time.now + expires_in).to_i if expires_in

        dynamodb_client.put_item(
          table_name: TABLE_NAME,
          item: data,
          condition_expression: 'attribute_not_exists(id)'
        )
        true
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
        false
      end

      def unlock!
        dynamodb_client.delete_item(
          table_name: TABLE_NAME,
          key: { id: @name }
        )
        true
      end

      def expired?
        saved_item = item
        return false unless saved_item
        expires_at = Time.at(saved_item['expires_at']) if saved_item['expires_at']
        expires_at && Time.now >= expires_at
      end

      private

      def item
        dynamodb_client.get_item(
          table_name: TABLE_NAME,
          key: { :id => @name },
          consistent_read: true
        ).item
      end

      def dynamodb_client
        return @dynamodb_client if @dynamodb_client
        @dynamodb_client = Aws::DynamoDB::Client.new

        begin
          @dynamodb_client.describe_table(table_name: TABLE_NAME)
        rescue Aws::DynamoDB::Errors::ResourceNotFoundException
          @dynamodb_client.create_table(
            table_name: TABLE_NAME,
            attribute_definitions: [
              { attribute_name: 'id', attribute_type: 'S' }
            ],
            key_schema: [
              { attribute_name: 'id', key_type: 'HASH' }
            ],
            provisioned_throughput: {
              read_capacity_units: 5,
              write_capacity_units: 5
            }
          )
          begin
            @dynamodb_client.wait_until(:table_exists, table_name: TABLE_NAME) do |w|
              w.max_attempts = 10
              w.delay = 1
            end
          rescue Aws::Waiters::Errors::WaiterFailed => e
            fail "Cannot create table #{TABLE_NAME}: #{e.message}"
          end
        end

        @dynamodb_client
      end
    end
  end
end
