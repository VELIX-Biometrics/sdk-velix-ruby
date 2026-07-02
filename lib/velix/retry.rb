# frozen_string_literal: true

module Velix
  module Retry
    RETRYABLE_STATUSES = [429, 503].freeze
    IDEMPOTENT_METHODS = %w[GET].freeze

    # Retries are only safe for:
    # - idempotent HTTP methods (GET), regardless of status
    # - RETRYABLE_STATUSES (429/503), where the server guarantees the
    #   request was not processed, even for non-idempotent methods (POST)
    #
    # Any other 5xx on a non-idempotent method (POST/PATCH/PUT/DELETE) is
    # raised immediately — retrying could duplicate a checkin/enroll.
    def with_retry(max_retries:, method: "GET")
      attempts = 0
      begin
        attempts += 1
        yield
      rescue RateLimitError, ServerError => e
        raise unless retryable?(method, e.status)
        raise if attempts >= max_retries

        wait = (2**(attempts - 1)) + rand
        sleep(wait)
        retry
      end
    end

    private

    def retryable?(method, status)
      IDEMPOTENT_METHODS.include?(method.to_s.upcase) || RETRYABLE_STATUSES.include?(status)
    end
  end
end
