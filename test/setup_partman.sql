-- pg_partman retention test setup
-- Creates 1-minute partitions, inserts test data, configures 5-minute retention

\echo ''
\echo '=== pg_partman SETUP ==='
\echo ''

-- Cleanup
DELETE FROM partman.part_config WHERE parent_table = 'public.events';
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS partman.template_public_events CASCADE;

\echo '✓ Cleanup done'

-- Create extension
CREATE SCHEMA IF NOT EXISTS partman;
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;

-- Create partitioned table (NO default partition!)
CREATE TABLE events (
    id SERIAL,
    event_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    data TEXT
) PARTITION BY RANGE (event_time);

\echo '✓ Table created'

-- Setup pg_partman: 1-minute partitions, start 10 min ago, premake 5
SELECT partman.create_parent(
    p_parent_table := 'public.events',
    p_control := 'event_time',
    p_interval := '1 minute',
    p_premake := 5,
    p_start_partition := (date_trunc('minute', now()) - interval '10 minutes')::text
);

-- Create historical partitions (MUST run before inserting old data!)
SELECT partman.run_maintenance('public.events');

\echo '✓ Partitions created'

-- Show partitions
\echo ''
\echo 'Partitions:'
SELECT tablename FROM pg_tables WHERE tablename LIKE 'events_p%' ORDER BY tablename;
SELECT COUNT(*) as partition_count FROM pg_tables WHERE tablename LIKE 'events_p%';

-- Insert 100 records: 10 per minute, across last 10 minutes
INSERT INTO events (event_time, data)
SELECT
    date_trunc('minute', now()) - (((i-1) / 10) * interval '1 minute') + (((i-1) % 10) * interval '5 seconds'),
    'event_' || i::text
FROM generate_series(1, 100) AS i;

\echo ''
\echo '✓ 100 records inserted (10 per minute, last 10 minutes)'

-- Show data distribution
\echo ''
\echo 'Data per partition:'
SELECT 
    tableoid::regclass::text as partition,
    COUNT(*) as records
FROM events 
GROUP BY tableoid 
ORDER BY partition;

-- Configure retention: 5 minutes
UPDATE partman.part_config
SET retention = '5 minutes',
    retention_keep_table = false
WHERE parent_table = 'public.events';

\echo ''
\echo '✓ Retention set to 5 minutes'
\echo ''
\echo '=== SETUP COMPLETE ==='
\echo ''
SELECT 
    (SELECT COUNT(*) FROM pg_tables WHERE tablename LIKE 'events_p%') as partitions,
    (SELECT COUNT(*) FROM events) as records;
\echo ''
