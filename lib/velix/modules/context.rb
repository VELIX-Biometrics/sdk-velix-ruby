# frozen_string_literal: true

module Velix
  module Modules
    # /v1/contexts/* — Identity Context (Velix.ID). BearerAuth (JWT de sessão).
    # Ver code/lib/lib-velix-contracts/openapi/public-api.yaml, tag "Identity Context".
    class Context
      def initialize(client)
        @client = client
      end

      def create(payload)
        @client.post("/v1/contexts", payload)
      end

      def get(id)
        @client.get("/v1/contexts/#{id}")
      end

      def list
        @client.get("/v1/contexts")
      end

      def update(id, payload)
        @client.patch("/v1/contexts/#{id}", payload)
      end

      def remove(id)
        @client.delete("/v1/contexts/#{id}")
      end

      # POST /v1/contexts/{contextId}/authorize — Authorization Engine.
      def authorize(context_id, payload)
        @client.post("/v1/contexts/#{context_id}/authorize", payload)
      end

      def list_authorization_decisions(context_id)
        @client.get("/v1/contexts/#{context_id}/authorization-decisions")
      end

      # POST /v1/contexts/{contextId}/link-requests — solicita vínculo cross-tenant.
      # Nunca cria membership diretamente: retorna 202 (PENDING) aguardando
      # consentimento via magic link/notificação. A API pública não expõe
      # approve/reject — isso acontece fora do SDK.
      def create_link_request(context_id, payload)
        @client.post("/v1/contexts/#{context_id}/link-requests", payload)
      end
    end

    class ContextMembership
      def initialize(client)
        @client = client
      end

      def create(context_id, payload)
        @client.post("/v1/contexts/#{context_id}/memberships", payload)
      end

      def list_by_context(context_id)
        @client.get("/v1/contexts/#{context_id}/memberships")
      end

      def list_by_identity(identity_id)
        @client.get("/v1/identities/#{identity_id}/memberships")
      end

      # status="revoked" é a saída de contexto (definitiva, sem carência, task #834).
      def update_status(membership_id, status)
        @client.patch("/v1/memberships/#{membership_id}/status", { status: status })
      end

      def add_roles(membership_id, role_ids)
        @client.post("/v1/memberships/#{membership_id}/roles", { roleIds: role_ids })
      end

      def remove_roles(membership_id, role_ids)
        @client.post("/v1/memberships/#{membership_id}/roles/remove", { roleIds: role_ids })
      end
    end

    class ContextRole
      def initialize(client)
        @client = client
      end

      def create(payload)
        @client.post("/v1/context-roles", payload)
      end

      def list(context_type)
        @client.get("/v1/context-roles", { contextType: context_type })
      end

      def link_permissions(role_id, permission_ids)
        @client.post("/v1/context-roles/#{role_id}/permissions", { permissionIds: permission_ids })
      end
    end

    class ContextPermission
      def initialize(client)
        @client = client
      end

      def create(payload)
        @client.post("/v1/context-permissions", payload)
      end

      def list(category: nil)
        @client.get("/v1/context-permissions", category ? { category: category } : {})
      end
    end

    class AuthorizationToken
      def initialize(client)
        @client = client
      end

      # POST /v1/authorization-tokens/validate — valida (e opcionalmente consome) um token vat_*.
      def validate(token, consume: false)
        @client.post("/v1/authorization-tokens/validate", { token: token, consume: consume })
      end
    end
  end
end
