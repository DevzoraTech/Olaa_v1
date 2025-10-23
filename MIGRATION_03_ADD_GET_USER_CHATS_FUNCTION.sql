-- ============================================================================
-- MIGRATION 03: Add get_user_chats Function
-- ============================================================================
-- This migration creates the get_user_chats RPC function
-- Run this in your Supabase SQL Editor
-- ============================================================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS get_user_chats(UUID);

-- Create the get_user_chats function
CREATE OR REPLACE FUNCTION get_user_chats(user_uuid UUID)
RETURNS TABLE (
  id UUID,
  is_group BOOLEAN,
  group_name TEXT,
  group_description TEXT,
  group_image_url TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  last_message_at TIMESTAMPTZ,
  last_message TEXT,
  last_message_sender_id UUID
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    c.id,
    c.is_group,
    c.group_name,
    c.group_description,
    c.group_image_url,
    c.created_at,
    c.updated_at,
    c.last_message_at,
    c.last_message,
    c.last_message_sender_id
  FROM chats c
  INNER JOIN chat_participants cp ON c.id = cp.chat_id
  WHERE cp.user_id = user_uuid
  ORDER BY c.last_message_at DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_chats(UUID) TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test the function (replace with your actual user ID)
-- SELECT * FROM get_user_chats('00000000-0000-0000-0000-000000000000'::UUID);

-- Check if function exists
SELECT
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'get_user_chats';

-- Expected output:
-- routine_name      | routine_type
-- ------------------+-------------
-- get_user_chats    | FUNCTION
