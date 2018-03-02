require 'rspec'
require 'fake_dynamo'
require 'aws-sdk'

Aws.config.update({
  credentials: Aws::Credentials.new(
    'your_access_key_id',
    'your_secret_access_key'
  ),
  endpoint: 'http://localhost:4567'
})

require 'semaphore'

RSpec.configure do |config|
  dynamo_thread = nil

  config.before(:suite) do
    FakeDynamo::Logger.setup(:debug)
    FakeDynamo::Storage.instance.init_db('test.fdb')
    FakeDynamo::Storage.instance.load_aof

    dynamo_thread = Thread.new do
      FakeDynamo::Server.run!(port: 4567, bind: 'localhost') do |server|
        if server.respond_to?('config') && server.config.respond_to?('[]=')
          server.config[:AccessLog] = []
        end
      end
    end
    sleep(1)
  end

  config.after(:suite) do
    FakeDynamo::Storage.instance.shutdown
    dynamo_thread.exit if dynamo_thread
    FileUtils.rm('test.fdb', force: true)
  end
end
