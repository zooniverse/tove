require 'rails_helper'
require 'retryable'

RSpec.describe Retryable do
  class DummyClass
    def process
      with_retries(
        rescue_class: [Faraday::ConnectionFailed, Faraday::TimeoutError, Errno::ECONNREFUSED]
      ) { self.call_me_maybe }
    end

    # Can't raise the exception directly or it won't retry
    def call_me_maybe
      return "success"
    end
  end

  let(:dummy_class) { DummyClass.new }

  before(:each) do
    # No waiting for the interval, no retry timing randomness
    stub_const("Retryable::SLEEP_INTERVAL", 0.0)
    allow_any_instance_of(Object).to receive(:rand).and_return(0.0)
    dummy_class.extend(Retryable)
  end

  it 'tries 4 times, then re-raises the error' do
    expect(dummy_class).to receive(:call_me_maybe).exactly(4).times.and_raise(Faraday::TimeoutError)
    expect {
      expect(dummy_class.process)
    }.to raise_error(Faraday::TimeoutError)
  end

  it 'retries once then succeeds' do
    expect(dummy_class).to receive(:call_me_maybe).once.and_raise(Errno::ECONNREFUSED)
    expect(dummy_class).to receive(:call_me_maybe).once.and_return("success")
    expect(dummy_class.process).to eq("success")
  end
end
