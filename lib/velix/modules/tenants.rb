# frozen_string_literal: true

module Velix
  module Modules
    class Tenants
      def initialize(client)
        @client = client
      end

      def me
        @client.get("/v1/tenants/me")
      end

      def update_settings(settings)
        @client.put("/v1/tenants/me/settings", settings)
      end
    end
  end
end
