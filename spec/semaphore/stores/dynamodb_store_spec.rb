require 'spec_helper'
require 'semaphore/stores/dynamodb_store'

describe Semaphore::Stores::DynamodbStore do
  let(:name) { 'some.lock' }
  subject { Semaphore::Stores::DynamodbStore.new(name) }
  after { subject.unlock! }

  it 'should have a name' do
    expect(subject.name).to eq(name)
  end

  it 'should lock' do
    expect(subject.lock!).to eq(true)
  end

  it 'should unlock' do
    expect(subject.unlock!).to eq(true)
  end

  it 'should know if it is locked' do
    expect(subject.locked?).to eq(false)
    subject.lock!
    expect(subject.locked?).to eq(true)
    subject.unlock!
    expect(subject.locked?).to eq(false)
  end
end
