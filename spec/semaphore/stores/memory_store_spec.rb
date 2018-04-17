require 'spec_helper'

describe Semaphore::Stores::MemoryStore do
  let(:name) { 'some.lock' }
  subject { Semaphore::Stores::MemoryStore.new(name) }

  it 'should have a name' do
    expect(subject.name).to eq(name)
  end

  it 'should lock' do
    expect(subject.lock!).to eq(true)
  end

  it 'should lock with expiration' do
    subject.lock!(expires_in: 1)
    expect(subject.expired?).to eq(false)
    sleep 1
    expect(subject.expired?).to eq(true)
  end

  it 'should unlock and clear the expiration' do
    subject.lock!(expires_in: 1)
    subject.unlock!
    expect(subject.expired?).to eq(false)
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
