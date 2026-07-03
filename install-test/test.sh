#!/usr/bin/env bash
# Builda a gem real (gem build) e instala num GEM_HOME separado — não usa
# o repo local via $LOAD_PATH como o smoke_test.rb faz.
set -e
cd "$(dirname "$0")/.."

gem build velix.gemspec -o /tmp/velix-sdk.gem

rm -rf /tmp/velix-install-test-rb
mkdir -p /tmp/velix-install-test-rb
gem install --install-dir /tmp/velix-install-test-rb --no-document /tmp/velix-sdk.gem

GEM_HOME=/tmp/velix-install-test-rb GEM_PATH=/tmp/velix-install-test-rb ruby -E utf-8 -e "
gem 'velix-sdk'
require 'velix'
client = Velix::Client.new(api_url: 'http://localhost', api_key: 'test')
raise 'client.onboarding missing from installed package' unless client.onboarding.respond_to?(:create)
puts 'INSTALL_TEST:ruby:PASS: gem instalada via gem build/install, client.onboarding existe'
"
