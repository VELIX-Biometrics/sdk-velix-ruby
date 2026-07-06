# velix-sdk — Ruby SDK ![version](https://img.shields.io/badge/version-0.1.0--alpha1-orange)

> ⚠️ **Alpha / pre-release**, mas já publicado e confirmado funcionando de ponta a ponta contra a API real de staging (onboarding, LGPD, me, events). **RubyGems:** https://rubygems.org/gems/velix-sdk

Official Ruby SDK for the VELIX Biometrics platform — facial access control B2B SaaS.

## Requirements

- Ruby 3.1+
- Zero runtime dependencies (uses stdlib `net/http`)

## Installation

Add to your `Gemfile`:

```ruby
gem "velix-sdk", "~> 0.1.0.pre"
```

Then:

```bash
bundle install
```

Or install directly:

```bash
gem install velix-sdk
```

## Quick Start

```ruby
require "velix"

client = Velix::Client.new(
  api_url: ENV["VELIX_API_URL"],
  api_key: ENV["VELIX_API_KEY"]
)

result = client.checkin.identify(image_base64: frame_base64)
puts result.matched ? "GRANTED" : "DENIED"
```

Auth is sent as `x-api-key: vlx_<hex>` on every request (the API also accepts
`Authorization: Bearer vlx_<hex>` as an alternative, but the SDK always uses the
`x-api-key` header).

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `VELIX_API_URL` | Yes | API base URL (`https://api.velixbiometrics.com`) |
| `VELIX_API_KEY` | Yes | Integrator API key (`vlx_...`) |

## Modules

The API-key surface has exactly six real endpoints, one per method below. There is no
list/update/delete for persons, events, or tenants under `/v1/api/*` — do not expect
those methods.

| Module | Method | Endpoint | Scope |
|--------|--------|----------|-------|
| `client.onboarding` | `create()` | `POST /v1/api/onboarding` | `onboarding:write` |
| `client.checkin` | `identify()` | `POST /v1/api/checkin/identify` | `checkin:write` |
| `client.lgpd` | `create_deletion_request()` | `POST /v1/api/deletion-request` | `lgpd:write` |
| `client.me` | `find()` | `GET /v1/api/me/{personId}` | `me:read` |
| `client.events` | `create_guest()` | `POST /v1/api/events/{id}/guests` | `events:write` |
| `client.events` | `get_guest()` | `GET /v1/api/events/{id}/guests/{guestId}` | `events:read` |

`client.time` exists only as a stub that raises `NotImplementedError` — Velix Time has
no endpoint under `/v1/api/*` yet (see spec note "Velix Time — COBERTURA PARCIAL").

## Onboarding Module

```ruby
result = client.onboarding.create(
  name: "João Silva",
  frames: [frame1_base64, frame2_base64, frame3_base64], # min 1, tenant-configured minimum
  email: "joao@company.com",
  external_id: "EMP-001" # upserts by external key when provided
)
# result.person_id         => "uuid"
# result.identity_id       => "uuid"
# result.enrolled          => true
# result.frames_processed  => 3
# result.frames_results    => [...]
```

## Checkin Module

```ruby
result = client.checkin.identify(
  image_base64: frame_base64,
  top_k: 3,
  liveness: {
    token: challenge_token, # from GET /v1/public/checkin/{tenantSlug}/liveness/challenge
    samples: [{ action: "center", image_base64: sample_base64 }]
  }
)
# result.matched      => true
# result.subject_id   => "uuid"
# result.subject_name => "Ana Silva"
# result.liveness_ok  => true
```

Similarity and liveness scores are never returned by the API — only the
`matched`/`liveness_ok` booleans are exposed, by design.

## LGPD Module

```ruby
result = client.lgpd.create_deletion_request(person_id: "uuid")
# result.protocol_number => "PROTO-123"
```

## Me Module

```ruby
person = client.me.find("uuid")
# person.id, person.name, person.email, person.phone, person.photo_url, person.created_at
```

## Events Module

```ruby
guest = client.events.create_guest("event-uuid", name: "Ana", email: "ana@empresa.com")
# guest.id, guest.event_id, guest.status, guest.category_id

guest = client.events.get_guest("event-uuid", "guest-uuid")
```

## Error Handling

```ruby
begin
  result = client.checkin.identify(image_base64: frame)
rescue Velix::AuthError
  puts "Invalid API key"
rescue Velix::BiometricError => e
  puts "Face not recognized: #{e.message}"
rescue Velix::RateLimitError => e
  puts "Rate limit: #{e.message}"
rescue Velix::VelixError => e
  puts "HTTP #{e.status}: #{e.message}"
end
```

## Running Tests

```bash
bundle exec rspec                        # all tests
bundle exec rspec spec/checkin_spec.rb   # single file
bundle exec rspec --format documentation # verbose
```

## Local Development

```bash
git clone <repo>
bundle install
bundle exec rspec
```

## Get an API Key

Access the dashboard at **velixbiometrics.com** → Settings → API Keys → New Key.
