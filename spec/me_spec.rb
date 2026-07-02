# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Me do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#find" do
    it "returns person data" do
      stub_velix(:get, "/v1/api/me/uuid-1",
                 { "id" => "uuid-1", "name" => "Ana", "email" => "ana@empresa.com",
                   "phone" => nil, "photo_url" => nil, "created_at" => "2026-01-01T00:00:00Z" })

      result = client.me.find("uuid-1")

      expect(result.id).to eq("uuid-1")
      expect(result.name).to eq("Ana")
    end
  end
end
