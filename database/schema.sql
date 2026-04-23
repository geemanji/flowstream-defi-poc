-- FlowStream Database Schema
-- PostgreSQL 16+

CREATE TABLE IF NOT EXISTS streams (
    id              BIGSERIAL PRIMARY KEY,
    stream_id       BIGINT UNIQUE NOT NULL,
    sender          VARCHAR(42) NOT NULL,
    recipient       VARCHAR(42) NOT NULL,
    token           VARCHAR(42) NOT NULL,
    deposit         VARCHAR(78) NOT NULL,
    rate_per_second VARCHAR(78) NOT NULL,
    start_time      BIGINT NOT NULL,
    stop_time       BIGINT NOT NULL,
    withdrawn       VARCHAR(78) NOT NULL DEFAULT '0',
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    tx_hash         VARCHAR(66) NOT NULL,
    block_number    BIGINT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_streams_sender ON streams(sender);
CREATE INDEX IF NOT EXISTS idx_streams_recipient ON streams(recipient);
CREATE INDEX IF NOT EXISTS idx_streams_active ON streams(active);
CREATE INDEX IF NOT EXISTS idx_streams_token ON streams(token);

CREATE TABLE IF NOT EXISTS stream_events (
    id              BIGSERIAL PRIMARY KEY,
    stream_id       BIGINT NOT NULL REFERENCES streams(stream_id),
    event_type      VARCHAR(50) NOT NULL,
    tx_hash         VARCHAR(66) NOT NULL,
    block_number    BIGINT NOT NULL,
    data            JSONB NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stream_events_stream_id ON stream_events(stream_id);
CREATE INDEX IF NOT EXISTS idx_stream_events_type ON stream_events(event_type);

CREATE TABLE IF NOT EXISTS indexer_state (
    id              INT PRIMARY KEY DEFAULT 1,
    last_block      BIGINT NOT NULL DEFAULT 0,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO indexer_state (id, last_block) VALUES (1, 0) ON CONFLICT (id) DO NOTHING;

-- Useful views
CREATE OR REPLACE VIEW stream_summary AS
SELECT
    COUNT(*) AS total_streams,
    COUNT(*) FILTER (WHERE active = TRUE) AS active_streams,
    COALESCE(SUM(CAST(deposit AS NUMERIC)), 0) AS total_deposited,
    COALESCE(SUM(CAST(withdrawn AS NUMERIC)), 0) AS total_withdrawn
FROM streams;
