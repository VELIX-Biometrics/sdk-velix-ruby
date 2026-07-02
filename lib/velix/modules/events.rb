# frozen_string_literal: true

module Velix
  module Modules
    class Events
      def initialize(client)
        @client = client
      end

      def list(page: 1, limit: 20)
        @client.get("/v1/events", { page: page, limit: limit })
      end

      def find(id)
        @client.get("/v1/events/#{id}")
      end

      def create(attrs)
        @client.post("/v1/events", attrs)
      end

      def update_config(id, config)
        @client.patch("/v1/events/#{id}/config", config)
      end

      def delete(id)
        @client.delete("/v1/events/#{id}")
      end
    end
  end
end
