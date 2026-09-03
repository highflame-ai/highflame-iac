-- Per-service databases for the air-gapped evaluation stack.
--
-- Runs once, on first boot, before any Highflame service starts. It creates
-- EMPTY databases only — every service owns its own schema and applies its own
-- migrations at startup, so there are no table definitions here to drift from
-- the code.
--
-- Deliberately NOT seeded here: the evaluator's tenant and membership rows.
-- Those live in bootstrap/seed-tenant.sh instead, because account_members does
-- not exist yet at this point — Admin creates it during its first-boot
-- migration, which happens after initdb has finished.

-- Keycloak's own store. Kept separate so wiping the realm cannot disturb
-- platform data, and so a customer swapping Keycloak for their existing IdP can
-- simply drop this database.
CREATE DATABASE keycloak;

-- AuthN (identity, service keys, ZeroID token issuance).
CREATE DATABASE highflame_authn;

-- Admin opens connections to all three of these at startup, not lazily, so a
-- missing one is a boot failure rather than a feature that quietly does not
-- work. Taken from the dsn list in Admin's own config rather than guessed:
--   javelin_data      primary store (tenancy, gateways, policy)
--   javelin_redteam   redteam + palisade
--   highflame_guardian guardrails
CREATE DATABASE javelin_redteam;
CREATE DATABASE highflame_guardian;

-- javelin_data (Admin, Shield, tenancy) is created by POSTGRES_DB in compose.

-- pgvector, in the database that needs it.
--
-- The image ships the extension's files; it does not install it into any
-- database. Admin creates prompt_embeddings on first boot and dies with
--   type "vector" does not exist (SQLSTATE=42704)
-- if this has not run — a fatal, crash-looping start, and the message names
-- postgres rather than the missing CREATE EXTENSION.
--
-- Per-database, not cluster-wide, so it has to be inside a \connect.
-- javelin_redteam is the one Admin builds prompt_embeddings in; javelin_data
-- gets it too because Shield's prompt store lives there and the cost of an
-- unused extension is nil next to another crash-loop that names postgres
-- instead of the missing statement.
\connect javelin_redteam
CREATE EXTENSION IF NOT EXISTS vector;
\connect javelin_data
CREATE EXTENSION IF NOT EXISTS vector;
\connect postgres

\echo 'air-gapped eval: databases created (keycloak, highflame_authn, javelin_redteam, highflame_guardian, javelin_data)'
