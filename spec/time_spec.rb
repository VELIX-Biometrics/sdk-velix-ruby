# frozen_string_literal: true

require "spec_helper"

RSpec.describe Velix::Modules::Time do
  let(:client) do
    Velix::Client.new(api_url: "https://api.velixbiometrics.com", api_key: "vx_test_key")
  end

  it "raises NotImplementedError for any call — Velix Time has no /v1/api/* endpoint yet" do
    expect { client.time.punch(person_id: "uuid-1") }.to raise_error(NotImplementedError)
  end
end
