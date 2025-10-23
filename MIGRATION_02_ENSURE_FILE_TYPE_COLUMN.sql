-- ============================================================================
-- MIGRATION 02: Ensure file_type Column Exists
-- ============================================================================
-- This migration ensures the file_type column exists in the messages table
-- Run this in your Supabase SQL Editor if you ran an older version of the setup
-- ============================================================================

-- Check if file_type column exists, add if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'messages'
    AND column_name = 'file_type'
  ) THEN
    ALTER TABLE messages ADD COLUMN file_type TEXT;
    RAISE NOTICE 'Added file_type column to messages table';
  ELSE
    RAISE NOTICE 'file_type column already exists - no changes needed';
  END IF;
END $$;

-- Verify the column exists
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'messages'
AND column_name = 'file_type';

-- Expected output:
-- column_name | data_type | is_nullable
-- ------------+-----------+-------------
-- file_type   | text      | YES
