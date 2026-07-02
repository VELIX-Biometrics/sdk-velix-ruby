# frozen_string_literal: true

module Velix
  module Modules
    # POST /v1/api/checkin/identify — scope checkin:write
    #
    # Liveness score is never returned by the API by design (security rule) —
    # this endpoint's response only ever reports `matched`, never a raw
    # liveness/confidence score.
    class Checkin
      Result = Data.define(:matched, :person_id, :quality_score, :message)

      def initialize(client)
        @client = client
      end

      # image_base64: main frame, required
      # images: optional array of extra base64 frames
      # top_k: optional integer 1..10
      # liveness: optional { token:, samples: [{ action:, image_base64: }] }
      # location: optional { latitude:, longitude:, accuracy: }
      def identify(image_base64:, images: nil, top_k: nil, liveness: nil, location: nil)
        body = { imageBase64: image_base64 }
        body[:images] = images if images
        body[:topK] = top_k if top_k
        body[:liveness] = serialize_liveness(liveness) if liveness
        body[:location] = location if location

        resp = @client.post("/v1/api/checkin/identify", body)

        Result.new(
          matched: resp["matched"],
          person_id: resp["person_id"],
          quality_score: resp["quality_score"],
          message: resp["message"]
        )
      end

      private

      # Maps idiomatic Ruby keys (token:, samples: [{ action:, image_base64: }])
      # onto the wire's literal camelCase field names (token, samples[].action,
      # samples[].imageBase64) as defined by LivenessBlock/LivenessSample in
      # the spec.
      def serialize_liveness(liveness)
        {
          token: liveness[:token],
          samples: Array(liveness[:samples]).map do |sample|
            { action: sample[:action], imageBase64: sample[:image_base64] || sample[:imageBase64] }
          end
        }
      end
    end
  end
end
