# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Checkin do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#facial" do
    it "returns passed true on successful identify" do
      stub_velix(:post, "/v1/checkin/acme/identify",
                 { "passed" => true, "personId" => "uuid-123", "personName" => "João Silva", "confidence" => 0.92 })

      result = client.checkin.facial("acme", "base64framedata")

      expect(result.passed).to be true
      expect(result.person_id).to eq("uuid-123")
      expect(result.person_name).to eq("João Silva")
      expect(result.confidence).to eq(0.92)
    end

    it "returns passed false when face not recognized" do
      stub_velix(:post, "/v1/checkin/acme/identify",
                 { "passed" => false, "personId" => nil, "personName" => nil, "confidence" => 0.0 })

      result = client.checkin.facial("acme", "base64framedata")

      expect(result.passed).to be false
      expect(result.person_id).to be_nil
    end
  end

  describe "#qr" do
    it "identifies via QR code" do
      stub_velix(:post, "/v1/checkin/acme/identify",
                 { "passed" => true, "personId" => "uuid-456", "personName" => "Maria", "confidence" => nil })

      result = client.checkin.qr("acme", "QR_CODE_VALUE")
      expect(result.passed).to be true
    end
  end
end
