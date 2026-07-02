# frozen_string_literal: true

module Velix
  module Modules
    # GET /v1/api/me/{personId} — scope me:read
    class Me
      Result = Data.define(:id, :name, :email, :phone, :photo_url, :created_at)

      def initialize(client)
        @client = client
      end

      def find(person_id)
        resp = @client.get("/v1/api/me/#{person_id}")

        Result.new(
          id: resp["id"],
          name: resp["name"],
          email: resp["email"],
          phone: resp["phone"],
          photo_url: resp["photo_url"],
          created_at: resp["created_at"]
        )
      end
    end
  end
end
