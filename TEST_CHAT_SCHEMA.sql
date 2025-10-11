-- Test Script for Chat Functions
-- Run this after applying FIX_CHAT_SCHEMA_ISSUES.sql

-- Test 1: Check if profiles table has the required columns
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
  AND column_name IN ('is_online', 'last_seen')
ORDER BY column_name;

-- Test 2: Check if foreign keys exist
SELECT 
  tc.constraint_name, 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('chat_participants', 'messages', 'chats')
ORDER BY tc.table_name, tc.constraint_name;

-- Test 3: Check if functions exist
SELECT 
  routine_name, 
  routine_type, 
  data_type
FROM information_schema.routines 
WHERE routine_name IN ('get_user_chats', 'get_chat_participants_with_profiles')
ORDER BY routine_name;

-- Test 4: Test the functions (replace with actual user/chat IDs)
-- SELECT * FROM get_user_chats('your-user-id-here');
-- SELECT * FROM get_chat_participants_with_profiles('your-chat-id-here');

-- Test 5: Check RLS policies
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual
FROM pg_policies 
WHERE tablename IN ('messages', 'chat_participants', 'chats')
ORDER BY tablename, policyname;
