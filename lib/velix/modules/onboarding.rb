# frozen_string_literal: true

module Velix
  module Modules
    # POST /v1/api/onboarding — scope onboarding:write
    class Onboarding
      Result = Data.define(:person_id, :identity_id, :enrolled, :frames_processed,
                            :frames_results, :embedding_id, :message)

      def initialize(client)
        @client = client
      end

      # frames: array of base64 jpeg strings (no data URI prefix), min 1
      def create(name:, frames:, email: nil, phone: nil, document: nil, document_type: nil,
                 external_id: nil, metadata: nil, role: nil, access_groups: nil)
        body = { name: name, frames: frames }
        body[:email] = email if email
        body[:phone] = phone if phone
        body[:document] = document if document
        body[:document_type] = document_type if document_type
        body[:external_id] = external_id if external_id
        body[:metadata] = metadata if metadata
        body[:role] = role if role
        body[:access_groups] = access_groups if access_groups

        resp = @client.post("/v1/api/onboarding", body)

        Result.new(
          person_id: resp["person_id"],
          identity_id: resp["identity_id"],
          enrolled: resp["enrolled"],
          frames_processed: resp["frames_processed"],
          frames_results: resp["frames_results"],
          embedding_id: resp["embedding_id"],
          message: resp["message"]
        )
      end
    end
  end
end
