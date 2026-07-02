# velix-sdk — Ruby SDK ![version](https://img.shields.io/badge/version-0.1.0--alpha1-orange)

> ⚠️ **Alpha / pre-release.** This SDK targets a public API surface that does not yet fully exist on the VELIX backend (see internal task #593). Endpoints and auth may not work against production. Do not use in production integrations yet.

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

result = client.checkin.facial("tenant-slug", frame_base64)
puts result.passed ? "GRANTED" : "DENIED"
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `VELIX_API_URL` | Yes | API base URL (`https://api.velixbiometrics.com`) |
| `VELIX_API_KEY` | Yes | Tenant API key (`vx_live_...` or `vx_sandbox_...`) |

## Modules

| Module | Methods |
|--------|---------|
| `client.checkin` | `facial()`, `qr()`, `pin()`, `get_history()` |
| `client.persons` | `list()`, `get()`, `create()`, `update()`, `delete()`, `enroll()` |
| `client.events` | `list()`, `get()`, `create()`, `configure()` |
| `client.tenants` | `me()`, `update_settings()` |

## Checkin Module

```ruby
checkin = client.checkin

# Facial identification (base64 JPEG frame)
result = checkin.facial("tenant-slug", frame_base64)
# result.passed      => true
# result.person_id   => "uuid"
# result.person_name => "João Silva"

# QR code checkin
result = checkin.qr("tenant-slug", qr_token)

# PIN checkin
result = checkin.pin("tenant-slug", pin)

# Paginated history
history = checkin.get_history("tenant-slug", page: 1, limit: 20)
# history.items  => [...]
# history.total  => 142
```

## Persons Module

```ruby
persons = client.persons

# List with optional search
list = persons.list(page: 1, limit: 20, search: "João")

# Get by ID
person = persons.get("uuid")

# Create
created = persons.create(
  name:        "João Silva",
  email:       "joao@company.com",
  external_id: "EMP-001"
)

# Update
persons.update("uuid", name: "João B. Silva")

# Enroll biometrics (minimum 3 base64 frames)
persons.enroll("uuid", [frame1, frame2, frame3])

# Delete
persons.delete("uuid")
```

## Events Module

```ruby
events = client.events

list    = events.list(page: 1, limit: 20)
event   = events.get("uuid")
created = events.create(name: "Annual Conference 2026", date: "2026-09-01")
events.configure("uuid", check_in_open: true, require_liveness: true)
```

## Tenants Module

```ruby
tenant = client.tenants.me
client.tenants.update_settings(require_liveness: true, biometric_quality_level: "high")
```

## Error Handling

```ruby
begin
  result = client.checkin.facial("slug", frame)
rescue Velix::AuthError
  puts "Invalid API key"
rescue Velix::BiometricError => e
  puts "Face not recognized: #{e.message}"
rescue Velix::RateLimitError => e
  puts "Rate limit — retry after #{e.retry_after}s"
rescue Velix::VelixError => e
  puts "HTTP #{e.status_code}: #{e.message}"
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
