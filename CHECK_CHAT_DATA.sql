-- Quick Check Script for Chat Data
-- Run this to see if there are any chats in the database

-- Check if chats table exists and has data
SELECT 
  'chats' as table_name,
  COUNT(*) as record_count
FROM chats
UNION ALL
SELECT 
  'chat_participants' as table_name,
  COUNT(*) as record_count
FROM chat_participants
UNION ALL
SELECT 
  'messages' as table_name,
  COUNT(*) as record_count
FROM messages;

-- Show sample chat data
SELECT 
  id,
  is_group,
  group_name,
  created_at,
  updated_at,
  last_message_at,
  last_message
FROM chats
ORDER BY created_at DESC
LIMIT 5;

-- Show sample chat participants
SELECT 
  cp.chat_id,
  cp.user_id,
  p.first_name,
  p.last_name
FROM chat_participants cp
LEFT JOIN profiles p ON cp.user_id = p.id
ORDER BY cp.joined_at DESC
LIMIT 10;

-- Show sample messages
SELECT 
  m.chat_id,
  m.sender_id,
  m.message,
  m.created_at,
  p.first_name,
  p.last_name
FROM messages m
LEFT JOIN profiles p ON m.sender_id = p.id
ORDER BY m.created_at DESC
LIMIT 10;

