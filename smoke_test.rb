#!/usr/bin/env ruby
# frozen_string_literal: true
system("bundle install --quiet") unless Dir.exist?("vendor/bundle") || ENV["SKIP_BUNDLE"]
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "velix"

IMG = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

def result(step, ok, detail)
  puts "RESULT:ruby:#{step}:#{ok ? 'PASS' : 'FAIL'}:#{detail}"
end

def reachable?(msg)
  m = msg.downcase
  %w[route\ not\ found no\ route 401 403].none? { |s| m.include?(s) }
end

client = Velix::Client.new(api_url: ENV.fetch("API_BASE_URL"), api_key: ENV.fetch("VELIX_API_KEY"))

person_id = nil
begin
  r = client.onboarding.create(name: "Smoke Test Ruby", frames: [IMG, IMG, IMG])
  person_id = r.respond_to?(:person_id) ? r.person_id : (r[:person_id] || r["person_id"])
  result("onboarding", !person_id.nil?, "person_id=#{person_id}")
rescue StandardError => e
  result("onboarding", false, e.message)
end

begin
  r = client.checkin.identify(image_base64: IMG)
  matched = r.respond_to?(:matched) ? r.matched : (r[:matched] || r["matched"])
  result("checkin", true, "matched=#{matched}")
rescue StandardError => e
  result("checkin", false, e.message)
end

if person_id
  begin
    client.lgpd.create_deletion_request(person_id: person_id)
    result("lgpd", true, "deletion-request ok")
  rescue StandardError => e
    result("lgpd", false, e.message)
  end

  begin
    client.me.find(person_id)
    result("me", true, "got response")
  rescue StandardError => e
    result("me", false, e.message)
  end
end

dummy = "00000000-0000-0000-0000-000000000000"
begin
  client.events.create_guest(dummy, name: "Guest Smoke", email: "guest@smoke.test")
  result("events_create", true, "endpoint reachable")
rescue StandardError => e
  result("events_create", reachable?(e.message), e.message)
end

begin
  client.events.get_guest(dummy, dummy)
  result("events_get", true, "endpoint reachable")
rescue StandardError => e
  result("events_get", reachable?(e.message), e.message)
end
