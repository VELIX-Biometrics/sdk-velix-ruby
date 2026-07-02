# frozen_string_literal: true

require "spec_helper"

RSpec.describe "retry behaviour" do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key",
                       max_retries: 3)
  end

  before { allow_any_instance_of(Object).to receive(:sleep) } # speed up backoff

  it "does not retry a POST on a plain 500 (non-idempotent, unsafe)" do
    stub_request(:post, "https://api.velixbiometrics.com/v1/api/onboarding")
      .to_return(status: 500, body: { message: "boom" }.to_json)

    expect { client.post("/v1/api/onboarding", { name: "Fulano" }) }
      .to raise_error(Velix::ServerError)

    expect(a_request(:post, "https://api.velixbiometrics.com/v1/api/onboarding")).to have_been_made.once
  end

  it "retries a POST on 503 (server guarantees it was not processed)" do
    stub_request(:post, "https://api.velixbiometrics.com/v1/api/onboarding")
      .to_return({ status: 503, body: { message: "unavailable" }.to_json })
      .to_return({ status: 201, body: { data: { ok: true } }.to_json })

    result = client.post("/v1/api/onboarding", { name: "Fulano" })
    expect(result["ok"]).to be true

    expect(a_request(:post, "https://api.velixbiometrics.com/v1/api/onboarding")).to have_been_made.twice
  end

  it "retries a GET on any 5xx (idempotent)" do
    stub_request(:get, "https://api.velixbiometrics.com/v1/api/me/1")
      .to_return({ status: 500, body: { message: "boom" }.to_json })
      .to_return({ status: 200, body: { data: { id: 1 } }.to_json })

    result = client.get("/v1/api/me/1")
    expect(result["id"]).to eq(1)

    expect(a_request(:get, "https://api.velixbiometrics.com/v1/api/me/1")).to have_been_made.twice
  end

  it "raises a structured VelixError instead of swallowing a malformed body" do
    stub_request(:get, "https://api.velixbiometrics.com/v1/api/me/1")
      .to_return(status: 500, body: "not json")

    expect { client.get("/v1/api/me/1") }.to raise_error(Velix::VelixError, /Failed to parse/)
  end
end
