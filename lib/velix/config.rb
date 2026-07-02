# frozen_string_literal: true

module Velix
  Config = Data.define(:api_url, :api_key, :timeout, :max_retries) do
    def initialize(api_url:, api_key:, timeout: 30, max_retries: 3)
      super
    end
  end
end
