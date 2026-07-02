# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Persons do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#list" do
    it "returns paginated persons" do
      stub_velix(:get, "/v1/persons",
                 { "items" => [{ "id" => "uuid-1", "name" => "João" }], "total" => 1 })

      result = client.persons.list
      expect(result["total"]).to eq(1)
    end
  end

  describe "#create" do
    it "creates a new person" do
      stub_velix(:post, "/v1/persons",
                 { "id" => "uuid-new", "name" => "Ana", "email" => "ana@empresa.com" },
                 status: 201)

      result = client.persons.create(name: "Ana", email: "ana@empresa.com")
      expect(result["id"]).to eq("uuid-new")
    end
  end

  describe "#enroll" do
    it "submits frames for biometric enrollment" do
      stub_velix(:post, "/v1/persons/uuid-1/enroll", { "enrolled" => true })

      result = client.persons.enroll("uuid-1", ["frame1", "frame2", "frame3"])
      expect(result["enrolled"]).to be true
    end
  end

  describe "#delete" do
    it "deletes a person" do
      stub_request(:delete, "https://api.velixbiometrics.com/v1/persons/uuid-1")
        .to_return(status: 204, body: "", headers: {})

      expect { client.persons.delete("uuid-1") }.not_to raise_error
    end
  end
end
