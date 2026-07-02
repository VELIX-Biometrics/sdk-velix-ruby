# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Events do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#create_guest" do
    it "creates a new guest" do
      stub_velix(:post, "/v1/api/events/evt-1/guests",
                 { "id" => "guest-1", "eventId" => "evt-1", "name" => "Ana",
                   "email" => "ana@empresa.com", "status" => "invited", "categoryId" => nil },
                 status: 201)

      guest = client.events.create_guest("evt-1", name: "Ana", email: "ana@empresa.com")

      expect(guest.id).to eq("guest-1")
      expect(guest.event_id).to eq("evt-1")
      expect(guest.status).to eq("invited")
    end
  end

  describe "#get_guest" do
    it "returns guest by id" do
      stub_velix(:get, "/v1/api/events/evt-1/guests/guest-1",
                 { "id" => "guest-1", "eventId" => "evt-1", "name" => "Ana",
                   "email" => "ana@empresa.com", "status" => "checked_in", "categoryId" => nil })

      guest = client.events.get_guest("evt-1", "guest-1")

      expect(guest.id).to eq("guest-1")
      expect(guest.status).to eq("checked_in")
    end

    it "raises VelixError on 404" do
      stub_request(:get, "https://api.velixbiometrics.com/v1/api/events/evt-1/guests/bad")
        .to_return(status: 404, body: { message: "Not found" }.to_json)

      expect { client.events.get_guest("evt-1", "bad") }.to raise_error(Velix::VelixError)
    end
  end
end
