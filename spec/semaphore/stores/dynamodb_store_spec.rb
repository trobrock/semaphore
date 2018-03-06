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

  it 'should lock with expiration' do
    subject.lock!(expires_in: 1)
    expect(subject.expires_at.to_i).to eq((Time.now + 1).to_i)
  end

  it 'should unlock and clear the expiration' do
    subject.lock!(expires_in: 1)
    subject.unlock!
    expect(subject.expires_at).to be_nil
  end

  it 'should clear unlock after expiration' do
    subject.lock!(expires_in: 1)
    expect(subject.locked?).to eq(true)
    sleep 1
    expect(subject.locked?).to eq(false)
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
