# frozen_string_literal: true

module Velix
  module Modules
    # /v1/api/events/{id}/guests — Velix Events guest endpoints.
    #
    # Only two operations exist in the real API: creating a guest
    # (events:write) and reading one back (events:read). There is no
    # list/find/create/update/delete-event or update-config endpoint under
    # the API-key surface — do not add methods for those without a
    # corresponding spec entry.
    class Events
      Guest = Data.define(:id, :event_id, :name, :email, :status, :category_id)

      def initialize(client)
        @client = client
      end

      # cpf, phone, birth_date, category_id, companion_of are optional.
      def create_guest(event_id, name:, email:, cpf: nil, phone: nil, birth_date: nil,
                        category_id: nil, companion_of: nil)
        body = { name: name, email: email }
        body[:cpf] = cpf if cpf
        body[:phone] = phone if phone
        body[:birthDate] = birth_date if birth_date
        body[:categoryId] = category_id if category_id
        body[:companionOf] = companion_of if companion_of

        resp = @client.post("/v1/api/events/#{event_id}/guests", body)
        build_guest(resp)
      end

      def get_guest(event_id, guest_id)
        resp = @client.get("/v1/api/events/#{event_id}/guests/#{guest_id}")
        build_guest(resp)
      end

      private

      def build_guest(resp)
        Guest.new(
          id: resp["id"],
          event_id: resp["eventId"],
          name: resp["name"],
          email: resp["email"],
          status: resp["status"],
          category_id: resp["categoryId"]
        )
      end
    end
  end
end
