# frozen_string_literal: true

module Velix
  module Modules
    class Persons
      def initialize(client)
        @client = client
      end

      def list(page: 1, limit: 20, search: nil)
        params = { page: page, limit: limit }
        params[:search] = search if search
        @client.get("/v1/persons", params)
      end

      def find(id)
        @client.get("/v1/persons/#{id}")
      end

      def create(attrs)
        @client.post("/v1/persons", attrs)
      end

      def update(id, attrs)
        @client.put("/v1/persons/#{id}", attrs)
      end

      def delete(id)
        @client.delete("/v1/persons/#{id}")
      end

      def enroll(id, frames)
        @client.post("/v1/persons/#{id}/enroll", { frames: frames })
      end
    end
  end
end
