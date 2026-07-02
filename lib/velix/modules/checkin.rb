# frozen_string_literal: true

module Velix
  module Modules
    class Checkin
      CheckinResult = Data.define(:passed, :person_id, :person_name, :confidence)

      def initialize(client)
        @client = client
      end

      def facial(tenant_slug, frame_base64, liveness_frames: [])
        resp = @client.post("/v1/checkin/#{tenant_slug}/identify", {
          frame: frame_base64,
          liveness_frames: liveness_frames
        })
        CheckinResult.new(
          passed: resp["passed"],
          person_id: resp["personId"],
          person_name: resp["personName"],
          confidence: resp["confidence"]
        )
      end

      def qr(tenant_slug, qr_code)
        resp = @client.post("/v1/checkin/#{tenant_slug}/identify", { qr_code: qr_code })
        CheckinResult.new(passed: resp["passed"], person_id: resp["personId"],
                          person_name: resp["personName"], confidence: nil)
      end

      def pin(tenant_slug, pin_code)
        resp = @client.post("/v1/checkin/#{tenant_slug}/identify", { pin: pin_code })
        CheckinResult.new(passed: resp["passed"], person_id: resp["personId"],
                          person_name: resp["personName"], confidence: nil)
      end
    end
  end
end
