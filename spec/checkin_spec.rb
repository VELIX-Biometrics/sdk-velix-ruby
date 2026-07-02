# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Checkin do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#identify" do
    it "returns matched true on successful identify" do
      stub_velix(:post, "/v1/api/checkin/identify",
                 { "matched" => true, "person_id" => "uuid-123", "quality_score" => 0.92,
                   "message" => "ok" })

      result = client.checkin.identify(image_base64: "base64framedata")

      expect(result.matched).to be true
      expect(result.person_id).to eq("uuid-123")
      expect(result.quality_score).to eq(0.92)
    end

    it "returns matched false when face not recognized" do
      stub_velix(:post, "/v1/api/checkin/identify",
                 { "matched" => false, "person_id" => nil, "quality_score" => 0.0,
                   "message" => "not found" })

      result = client.checkin.identify(image_base64: "base64framedata")

      expect(result.matched).to be false
      expect(result.person_id).to be_nil
    end

    it "sends liveness block mapped to wire camelCase field names" do
      stub_velix(:post, "/v1/api/checkin/identify",
                 { "matched" => true, "person_id" => "uuid-456", "quality_score" => 0.8,
                   "message" => "ok" })

      client.checkin.identify(
        image_base64: "frame",
        top_k: 3,
        liveness: {
          token: "nonce-abc",
          samples: [{ action: "center", image_base64: "sample1" }]
        }
      )

      expect(a_request(:post, "https://api.velixbiometrics.com/v1/api/checkin/identify")
        .with(body: hash_including(
          "topK" => 3,
          "liveness" => hash_including(
            "token" => "nonce-abc",
            "samples" => [hash_including("action" => "center", "imageBase64" => "sample1")]
          )
        ))).to have_been_made.once
    end
  end
end
