# frozen_string_literal: true

module Velix
  module Modules
    # POST /v1/api/deletion-request — scope lgpd:write
    class Lgpd
      Result = Data.define(:protocol_number, :message)

      def initialize(client)
        @client = client
      end

      def create_deletion_request(person_id:)
        resp = @client.post("/v1/api/deletion-request", { person_id: person_id })

        Result.new(protocol_number: resp["protocol_number"], message: resp["message"])
      end
    end
  end
end
