# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Onboarding do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#create" do
    it "enrolls a person with frames" do
      stub_velix(:post, "/v1/api/onboarding",
                 { "person_id" => "uuid-1", "identity_id" => "id-1", "enrolled" => true,
                   "frames_processed" => 3, "frames_results" => [], "embedding_id" => "emb-1",
                   "message" => "ok" },
                 status: 201)

      result = client.onboarding.create(name: "Ana", frames: %w[f1 f2 f3])

      expect(result.person_id).to eq("uuid-1")
      expect(result.enrolled).to be true
      expect(result.frames_processed).to eq(3)
    end

    it "sends optional external_id for upsert" do
      stub_velix(:post, "/v1/api/onboarding",
                 { "person_id" => "uuid-1", "identity_id" => "id-1", "enrolled" => true,
                   "frames_processed" => 1, "frames_results" => [], "embedding_id" => nil,
                   "message" => "ok" },
                 status: 201)

      client.onboarding.create(name: "Ana", frames: ["f1"], external_id: "ext-42")

      expect(a_request(:post, "https://api.velixbiometrics.com/v1/api/onboarding")
        .with(body: hash_including("external_id" => "ext-42"))).to have_been_made.once
    end
  end
end
