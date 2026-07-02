# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Tenants do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  describe "#me" do
    it "returns current tenant" do
      stub_request(:get, "https://api.velixbiometrics.com/v1/tenants/me")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { data: { id: "tenant-uuid", name: "Acme Corp", slug: "acme", plan: "enterprise" } }.to_json
        )

      tenant = client.tenants.me
      expect(tenant.id).to eq("tenant-uuid")
      expect(tenant.slug).to eq("acme")
      expect(tenant.plan).to eq("enterprise")
    end
  end

  describe "#update_settings" do
    it "updates and returns tenant settings" do
      stub_request(:put, "https://api.velixbiometrics.com/v1/tenants/me/settings")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { data: { id: "tenant-uuid", require_liveness: true, timezone: "America/Sao_Paulo" } }.to_json
        )

      tenant = client.tenants.update_settings(require_liveness: true, timezone: "America/Sao_Paulo")
      expect(tenant.require_liveness).to be true
      expect(tenant.timezone).to eq("America/Sao_Paulo")
    end
  end
end
