require 'spec_helper'

class CustomStore
  attr_reader :method_calls, :name

  def initialize(name)
    @name = name
    @method_calls = []
  end

  def locked?
    @method_calls << :locked?
    false
  end

  def lock!
    @method_calls << :lock!
    true
  end

  def unlock!
    @method_calls << :unlock!
    true
  end
end

describe Semaphore::Lock do
  subject { Semaphore::Lock.new('lock.name') }

  it 'should have a lock name' do
    expect(subject.name).to eq('lock.name')
  end

  it 'should acquire a lock' do
    expect(subject.lock).to eq(true)
  end

  context 'with a custom store' do
    subject { Semaphore::Lock.new('lock.name', store: CustomStore) }
    let(:store) { subject.instance_variable_get(:@backend) }

    it 'should use the custom store for locking' do
      subject.lock
      expect(store.method_calls).to eq(%i( locked? lock! ))
    end

    it 'should use the custom store for unlocking' do
      subject.unlock
      expect(store.method_calls).to eq(%i( unlock! ))
    end
  end

  context 'with a lock already acquired' do
    before { subject.lock }

    it 'should return false' do
      expect(subject.lock).to eq(false)
    end

    it 'should unlock' do
      expect(subject.unlock).to eq(true)
      expect(subject.lock).to eq(true)
    end

    it 'should block execution' do
      expect { Timeout::timeout(1) { subject.lock(wait_for: true) } }.to raise_error(Timeout::Error)
    end

    it 'should wait for specified seconds' do
      expect(Timeout::timeout(1.1) { subject.lock(wait_for: 1) }).to eq(false)
    end

    it 'should unblock if unlocked' do
      Thread.new do
        sleep 2
        subject.unlock
      end
      expect(Timeout::timeout(5) { subject.lock(wait_for: true) }).to eq(true)
    end

    it 'should call the before_wait block' do
      counter = 0
      Thread.new do
        sleep 2
        subject.unlock
      end
      expect(Timeout::timeout(5) { subject.lock(wait_for: true, before_wait: -> { counter += 1 }) }).to eq(true)
      expect(counter).to be > 0
    end
  end
end
