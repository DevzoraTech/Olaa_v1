-- Migration: Add 'location' message type to existing database
-- Run this in your Supabase SQL Editor if you already ran PRODUCTION_CHAT_SETUP.sql

-- Step 1: Drop the existing constraint
ALTER TABLE messages
DROP CONSTRAINT IF EXISTS messages_type_check;

-- Step 2: Add new constraint with 'location' included
ALTER TABLE messages
ADD CONSTRAINT messages_type_check
CHECK (type IN ('text', 'image', 'video', 'file', 'voice', 'link', 'location'));

-- Step 3: Verify the constraint was updated
SELECT
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'messages_type_check';

-- Expected output should show: type IN ('text', 'image', 'video', 'file', 'voice', 'link', 'location')
