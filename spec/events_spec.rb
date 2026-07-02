# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Events do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#list" do
    it "returns paged event list" do
      stub_request(:get, "https://api.velixbiometrics.com/v1/events")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { data: { items: [{ id: "evt-1", name: "Tech Summit", status: "active" }], total: 1, page: 1, limit: 20 } }.to_json
        )

      result = client.events.list
      expect(result.total).to eq(1)
      expect(result.items.first.id).to eq("evt-1")
    end
  end

  describe "#get" do
    it "returns event by id" do
      stub_request(:get, "https://api.velixbiometrics.com/v1/events/evt-1")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { data: { id: "evt-1", name: "Tech Summit", status: "active" } }.to_json
        )

      event = client.events.get("evt-1")
      expect(event.id).to eq("evt-1")
      expect(event.name).to eq("Tech Summit")
    end

    it "raises VelixError on 404" do
      stub_request(:get, "https://api.velixbiometrics.com/v1/events/bad")
        .to_return(status: 404, body: { message: "Not found" }.to_json)

      expect { client.events.get("bad") }.to raise_error(Velix::VelixError)
    end
  end

  describe "#create" do
    it "creates a new event" do
      stub_request(:post, "https://api.velixbiometrics.com/v1/events")
        .to_return(
          status: 201,
          headers: { "Content-Type" => "application/json" },
          body: { data: { id: "evt-new", name: "New Event", status: "draft" } }.to_json
        )

      event = client.events.create(name: "New Event")
      expect(event.id).to eq("evt-new")
      expect(event.status).to eq("draft")
    end
  end
end
