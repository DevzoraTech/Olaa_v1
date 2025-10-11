-- Fix Database Timezone Issues
-- This script addresses timezone problems that might cause future timestamps

-- Check current database timezone
SELECT 
  name,
  setting,
  unit,
  context
FROM pg_settings 
WHERE name IN ('timezone', 'log_timezone', 'TimeZone');

-- Check if there are any messages with future timestamps
SELECT 
  id,
  created_at,
  message,
  EXTRACT(EPOCH FROM (created_at - NOW())) as seconds_from_now
FROM messages 
WHERE created_at > NOW()
ORDER BY created_at DESC
LIMIT 10;

-- Update any messages with future timestamps to current time
-- (Only run this if you want to fix existing data)
-- UPDATE messages 
-- SET created_at = NOW() 
-- WHERE created_at > NOW();

-- Check the timezone of the database server
SELECT NOW() as current_db_time, 
       NOW() AT TIME ZONE 'UTC' as utc_time,
       NOW() AT TIME ZONE 'Africa/Kampala' as kampala_time;

-- Verify message timestamps are reasonable
SELECT 
  COUNT(*) as total_messages,
  COUNT(CASE WHEN created_at > NOW() THEN 1 END) as future_messages,
  COUNT(CASE WHEN created_at < NOW() - INTERVAL '1 year' THEN 1 END) as very_old_messages,
  MIN(created_at) as oldest_message,
  MAX(created_at) as newest_message
FROM messages;
