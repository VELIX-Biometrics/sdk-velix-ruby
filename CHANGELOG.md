# Changelog

Todas as mudanças notáveis deste projeto são documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
e este projeto adere a [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Fixed

- Retry deixou de reenviar cegamente qualquer `5xx`. Requisições não
  idempotentes (`POST`, `PATCH`, `PUT`, `DELETE`) só são retentadas quando o
  status é `429` ou `503` (`RETRYABLE_STATUSES`), casos em que o servidor
  garante que a requisição original não foi processada. Isso elimina o risco
  de duplicar `checkin`/`enroll` em erro `500`.
- Erros de parse do corpo da resposta deixaram de ser engolidos
  silenciosamente (`JSON.parse rescue {}`). Agora um corpo malformado
  propaga um `Velix::VelixError` estruturado em vez de virar `{}` e esconder
  a mensagem de erro original.

## [0.1.0.pre.alpha1] - pré-release

### Added

- Cliente HTTP baseado em `Net::HTTP` (stdlib, zero dependências de runtime).
- Autenticação via header `x-api-key`.
- Módulos `checkin`, `persons`, `events`, `tenants`.
- Retry com backoff exponencial para status retentáveis.
