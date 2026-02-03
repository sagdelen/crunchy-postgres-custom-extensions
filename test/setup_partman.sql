-- pg_partman extension oluştur
CREATE SCHEMA IF NOT EXISTS partman;
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;

-- Partition'lı tablo oluştur
CREATE TABLE IF NOT EXISTS events (
    id SERIAL,
    event_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    data TEXT
) PARTITION BY RANGE (event_time);

-- pg_partman ile dakikalık partition yönetimi
SELECT partman.create_parent(
    p_parent_table := 'public.events',
    p_control := 'event_time',
    p_interval := '1 minute',
    p_premake := 5,
    p_start_partition := (now() - interval '5 minutes')::text
);

-- Retention: 5 dakika (5 partition)
UPDATE partman.part_config
SET retention = '5 minutes',
    retention_keep_table = false,
    retention_keep_index = false
WHERE parent_table = 'public.events';

-- Random test data ekle (son 10 dakikaya yayılmış)
INSERT INTO events (event_time, data)
SELECT
    now() - (random() * interval '10 minutes'),
    md5(random()::text)
FROM generate_series(1, 100);

-- Durumu göster
SELECT tablename FROM pg_tables WHERE tablename LIKE 'events_p%' ORDER BY tablename;
