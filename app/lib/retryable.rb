module Retryable
  SLEEP_INTERVAL = 0.4

  def with_retries(retries: 3, rescue_class: )
    tries = 0

    begin
      yield
    rescue *rescue_class => e
      tries += 1
      if tries <= retries
        sleep sleep_interval(tries)
        retry
      else
        raise
      end
    end
  end

  private

  def sleep_interval(tries)
    (SLEEP_INTERVAL + rand(0.0..1.0)) * tries
  end
end