-- Fix for infinite recursion in chat_participants RLS policies
-- This script removes the problematic policies and creates better ones

-- Drop ALL existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to chats they're in" ON chat_participants;
DROP POLICY IF EXISTS "Users can view their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can view other participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;

-- Drop policies from other tables too
DROP POLICY IF EXISTS "Users can view chats they participate in" ON chats;
DROP POLICY IF EXISTS "Users can create chats" ON chats;
DROP POLICY IF EXISTS "Users can update chats they participate in" ON chats;
DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to chats they're in" ON messages;
DROP POLICY IF EXISTS "Users can edit their own messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- Alternative approach: Create a function to check chat participation
-- This function can be used in policies to avoid recursion
CREATE OR REPLACE FUNCTION user_is_chat_participant(chat_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM chat_participants 
    WHERE chat_id = chat_uuid AND user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION user_is_chat_participant(UUID, UUID) TO authenticated;

-- Create a function to get existing direct chat between two users
-- This avoids RLS recursion by using SECURITY DEFINER
CREATE OR REPLACE FUNCTION get_existing_direct_chat(user1_uuid UUID, user2_uuid UUID)
RETURNS UUID AS $$
DECLARE
  chat_id_result UUID;
BEGIN
  -- Find a direct chat that has both users as participants
  SELECT c.id INTO chat_id_result
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
  
  RETURN chat_id_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_existing_direct_chat(UUID, UUID) TO authenticated;

-- Now we can create even better policies using this function

-- Recreate policies using the function
CREATE POLICY "Users can view participants in their chats" ON chat_participants
  FOR SELECT USING (
    user_id = auth.uid() OR 
    user_is_chat_participant(chat_id, auth.uid())
  );

CREATE POLICY "Users can add participants to their chats" ON chat_participants
  FOR INSERT WITH CHECK (
    user_is_chat_participant(chat_id, auth.uid())
  );

-- Also fix the chats table policies to use the function

CREATE POLICY "Users can view chats they participate in" ON chats
  FOR SELECT USING (
    user_is_chat_participant(id, auth.uid())
  );

CREATE POLICY "Users can create chats" ON chats
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update chats they participate in" ON chats
  FOR UPDATE USING (
    user_is_chat_participant(id, auth.uid())
  );

-- Fix messages table policies too

CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    user_is_chat_participant(chat_id, auth.uid())
  );

CREATE POLICY "Users can send messages to chats they're in" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid() AND
    user_is_chat_participant(chat_id, auth.uid())
  );

CREATE POLICY "Users can edit their own messages" ON messages
  FOR UPDATE USING (
    sender_id = auth.uid() AND
    user_is_chat_participant(chat_id, auth.uid())
  );

CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid() AND
    user_is_chat_participant(chat_id, auth.uid())
  );
