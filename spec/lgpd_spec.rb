# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Lgpd do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#create_deletion_request" do
    it "returns a protocol number" do
      stub_velix(:post, "/v1/api/deletion-request",
                 { "protocol_number" => "PROTO-1", "message" => "registered" },
                 status: 201)

      result = client.lgpd.create_deletion_request(person_id: "uuid-1")

      expect(result.protocol_number).to eq("PROTO-1")
    end

    it "raises AuthError when person does not belong to the tenant" do
      stub_request(:post, "https://api.velixbiometrics.com/v1/api/deletion-request")
        .to_return(status: 403, body: { message: "forbidden" }.to_json)

      expect { client.lgpd.create_deletion_request(person_id: "uuid-x") }
        .to raise_error(Velix::AuthError)
    end
  end
end
