# frozen_string_literal: true

module Velix
  module Modules
    # Velix Time (ponto/punch) has NO endpoint exposed under the API-key
    # surface (`/v1/api/*`) as of the current public-api.yaml spec. The
    # `time:read`/`time:write` scopes exist on ApplicationApiKey but no
    # controller is mounted for them yet (see spec note "Velix Time —
    # COBERTURA PARCIAL"). Do not implement calls against guessed endpoints.
    #
    # This stub exists only so that any accidental `client.time` call fails
    # loudly instead of silently hitting a nonexistent/wrong endpoint.
    class Time
      def initialize(client)
        @client = client
      end

      def method_missing(name, *)
        raise NotImplementedError,
              "Velix::Modules::Time##{name} is not implemented — Velix Time has no endpoint " \
              "under /v1/api/* yet (see public-api.yaml, task #616 follow-up)."
      end

      def respond_to_missing?(*)
        true
      end
    end
  end
end
