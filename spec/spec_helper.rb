# frozen_string_literal: true

require "webmock/rspec"
require "json"
require_relative "../lib/velix"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end

def stub_velix(method, path, response_body, status: 200)
  stub_request(method, "https://api.velixbiometrics.com#{path}")
    .to_return(
      status: status,
      body: { data: response_body }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
end
