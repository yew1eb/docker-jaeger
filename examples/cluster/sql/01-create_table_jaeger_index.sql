CREATE TABLE IF NOT EXISTS tracing.jaeger_index (
    timestamp DateTime CODEC(Delta, ZSTD(1)),
    traceID String CODEC(ZSTD(1)),
    service LowCardinality(String) CODEC(ZSTD(1)),
    operation LowCardinality(String) CODEC(ZSTD(1)),
    durationUs UInt64 CODEC(ZSTD(1)),
    tags Array(String) CODEC(ZSTD(1)),
    INDEX idx_tags tags TYPE bloom_filter(0.01) GRANULARITY 64,
    INDEX idx_duration durationUs TYPE minmax GRANULARITY 1
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/tracing.jaeger_index', '{replica}')
PARTITION BY toDate(timestamp)
ORDER BY (service, -toUnixTimestamp(timestamp))
TTL toDate(timestamp) + INTERVAL 2 DAY DELETE
SETTINGS index_granularity = 1024
