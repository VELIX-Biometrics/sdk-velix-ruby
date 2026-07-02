# frozen_string_literal: true

module Velix
  class VelixError < StandardError
    attr_reader :status, :code

    def initialize(message, status: nil, code: nil)
      super(message)
      @status = status
      @code = code
    end
  end

  class AuthError < VelixError; end
  class NotFoundError < VelixError; end
  class RateLimitError < VelixError; end
  class BiometricError < VelixError; end
  class ServerError < VelixError; end
end
