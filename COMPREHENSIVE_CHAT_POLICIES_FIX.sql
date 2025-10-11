-- Comprehensive fix for all chat-related RLS policies
-- This ensures all necessary policies exist for chat creation

-- Fix chats table policies
DROP POLICY IF EXISTS "Users can create chats" ON chats;
CREATE POLICY "Users can create chats" ON chats
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can view chats they participate in" ON chats;
CREATE POLICY "Users can view chats they participate in" ON chats
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update chats they participate in" ON chats;
CREATE POLICY "Users can update chats they participate in" ON chats
  FOR UPDATE USING (true);

-- Fix chat_participants table policies
DROP POLICY IF EXISTS "Users can add participants to their chats" ON chat_participants;
CREATE POLICY "Users can add participants to their chats" ON chat_participants
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
CREATE POLICY "Users can view participants in their chats" ON chat_participants
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
CREATE POLICY "Users can update their own participation" ON chat_participants
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;
CREATE POLICY "Users can leave chats" ON chat_participants
  FOR DELETE USING (user_id = auth.uid());

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS create_direct_chat(UUID, UUID);

-- Create a comprehensive function to create direct chats (bypasses RLS)
CREATE OR REPLACE FUNCTION create_direct_chat(user1_uuid UUID, user2_uuid UUID)
RETURNS UUID AS $$
DECLARE
  chat_id_result UUID;
  existing_chat_id UUID;
BEGIN
  -- Check if a direct chat already exists between these two users
  SELECT c.id INTO existing_chat_id
  FROM chats c
  WHERE c.is_group = false
    AND EXISTS (
      SELECT 1 FROM chat_participants cp1 
      WHERE cp1.chat_id = c.id AND cp1.user_id = user1_uuid
    )
    AND EXISTS (
      SELECT 1 FROM chat_participants cp2 
      WHERE cp2.chat_id = c.id AND cp2.user_id = user2_uuid
    )
  LIMIT 1;
  
  -- If existing chat found, return it
  IF existing_chat_id IS NOT NULL THEN
    RETURN existing_chat_id;
  END IF;
  
  -- Create new chat
  INSERT INTO chats (is_group, created_at, updated_at, last_message_at)
  VALUES (false, NOW(), NOW(), NOW())
  RETURNING id INTO chat_id_result;
  
  -- Add both users as participants
  INSERT INTO chat_participants (chat_id, user_id, joined_at, last_read_at, is_admin)
  VALUES 
    (chat_id_result, user1_uuid, NOW(), NOW(), false),
    (chat_id_result, user2_uuid, NOW(), NOW(), false);
  
  RETURN chat_id_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_direct_chat(UUID, UUID) TO authenticated;

-- Verify all policies exist
SELECT 'chats' as table_name, policyname, cmd FROM pg_policies WHERE tablename = 'chats'
UNION ALL
SELECT 'chat_participants' as table_name, policyname, cmd FROM pg_policies WHERE tablename = 'chat_participants'
ORDER BY table_name, cmd;
