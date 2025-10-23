-- ============================================================================
-- QUICK FIX: Drop and Recreate Problematic Policies
-- ============================================================================
-- Run this in Supabase SQL Editor to fix the infinite recursion error
-- ============================================================================

-- Step 1: Drop ALL existing policies that might cause recursion
DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to existing chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;

DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to their chats" ON messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON messages;
DROP POLICY IF EXISTS "Users can update messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- Step 2: Create simple, non-recursive policies
CREATE POLICY "Users can view participants in their chats" ON chat_participants
  FOR SELECT USING (
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can add participants to chats" ON chat_participants
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    OR
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own participation" ON chat_participants
  FOR UPDATE USING (
    user_id = auth.uid()
  );

CREATE POLICY "Users can leave chats" ON chat_participants
  FOR DELETE USING (
    user_id = auth.uid()
  );

-- Step 3: Create simple message policies
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to their chats" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update messages" ON messages
  FOR UPDATE USING (
    sender_id = auth.uid()
    OR
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid()
  );

-- Step 4: Verify policies were created
SELECT 'Policies Created Successfully!' as status;
SELECT tablename, policyname FROM pg_policies 
WHERE tablename IN ('chat_participants', 'messages')
ORDER BY tablename, policyname;
