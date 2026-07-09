# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

require_relative "config"
require_relative "error"
require_relative "retry"
require_relative "modules/onboarding"
require_relative "modules/checkin"
require_relative "modules/lgpd"
require_relative "modules/me"
require_relative "modules/events"
require_relative "modules/time"
require_relative "modules/context"

module Velix
  class Client
    include Velix::Retry

    USER_AGENT = "velix-ruby-sdk/0.1.0.pre.alpha1"

    def initialize(api_url:, api_key:, timeout: 30, max_retries: 3)
      @config = Config.new(api_url: api_url, api_key: api_key,
                           timeout: timeout, max_retries: max_retries)
    end

    def onboarding = @onboarding ||= Modules::Onboarding.new(self)
    def checkin    = @checkin    ||= Modules::Checkin.new(self)
    def lgpd       = @lgpd       ||= Modules::Lgpd.new(self)
    def me         = @me         ||= Modules::Me.new(self)
    def events     = @events     ||= Modules::Events.new(self)

    # Velix Time has no endpoint under /v1/api/* yet — see modules/time.rb.
    def time = @time ||= Modules::Time.new(self)

    def contexts = @contexts ||= Modules::Context.new(self)
    def memberships = @memberships ||= Modules::ContextMembership.new(self)
    def context_roles = @context_roles ||= Modules::ContextRole.new(self)
    def context_permissions = @context_permissions ||= Modules::ContextPermission.new(self)
    def authorization_tokens = @authorization_tokens ||= Modules::AuthorizationToken.new(self)

    def get(path, params = {})
      uri = build_uri(path, params)
      request(Net::HTTP::Get.new(uri))
    end

    def post(path, body = {})
      uri = build_uri(path)
      req = Net::HTTP::Post.new(uri)
      req.body = body.to_json
      request(req)
    end

    def put(path, body = {})
      uri = build_uri(path)
      req = Net::HTTP::Put.new(uri)
      req.body = body.to_json
      request(req)
    end

    def patch(path, body = {})
      uri = build_uri(path)
      req = Net::HTTP::Patch.new(uri)
      req.body = body.to_json
      request(req)
    end

    def delete(path)
      uri = build_uri(path)
      request(Net::HTTP::Delete.new(uri))
    end

    private

    def build_uri(path, params = {})
      uri = URI.join(@config.api_url, path)
      uri.query = URI.encode_www_form(params) unless params.empty?
      uri
    end

    def request(req)
      req["x-api-key"] = @config.api_key
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req["User-Agent"] = USER_AGENT

      with_retry(max_retries: @config.max_retries, method: req.method) do
        uri = req.uri
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = @config.timeout
        http.read_timeout = @config.timeout

        response = http.request(req)
        handle_response(response)
      end
    end

    def handle_response(response)
      body = parse_body(response.body)
      # Envelope de erro real: {"success":false,"error":{"code":"...","message":"..."}}.
      # body["message"] no nível raiz não existe — ficava sempre no fallback
      # genérico, mascarando a mensagem real da API.
      message = body.is_a?(Hash) ? body.dig("error", "message") || body["message"] : nil

      case response.code.to_i
      when 200, 201, 204
        body.is_a?(Hash) && body.key?("data") ? body["data"] : body
      when 401, 403
        raise AuthError.new(message || "Unauthorized", status: response.code.to_i)
      when 404
        raise NotFoundError.new(message || "Not found", status: 404)
      when 422
        raise BiometricError.new(message || "Unprocessable", status: 422)
      when 429
        raise RateLimitError.new(message || "Rate limit exceeded", status: 429)
      when 500..599
        raise ServerError.new(message || "Server error", status: response.code.to_i)
      else
        raise VelixError.new(message || "Unexpected error", status: response.code.to_i)
      end
    end

    # Parse errors are never swallowed: a malformed body on an error
    # response must still surface as a structured VelixError instead of
    # silently becoming an empty hash (which hides the real failure and
    # nils out the error message).
    def parse_body(raw)
      return {} if raw.nil? || raw.empty?

      JSON.parse(raw)
    rescue JSON::ParserError => e
      raise VelixError.new("Failed to parse response body: #{e.message}", status: nil, code: "invalid_json")
    end
  end
end
