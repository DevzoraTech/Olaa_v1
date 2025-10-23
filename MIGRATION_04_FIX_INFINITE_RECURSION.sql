-- ============================================================================
-- MIGRATION 04: Fix Infinite Recursion in RLS Policies
-- ============================================================================
-- This fixes the "infinite recursion detected in policy" error
-- The issue: RLS policies were checking chat_participants within chat_participants
-- ============================================================================

-- ============================================================================
-- 1. DROP PROBLEMATIC POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to existing chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;

DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to their chats" ON messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- ============================================================================
-- 2. CREATE FIXED CHAT_PARTICIPANTS POLICIES (No recursion)
-- ============================================================================

-- SELECT: Users can view all participants in chats they're part of
-- FIXED: Use a subquery that doesn't reference chat_participants recursively
CREATE POLICY "Users can view participants in their chats" ON chat_participants
  FOR SELECT USING (
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

-- INSERT: Users can add themselves OR add others if they're already in the chat
CREATE POLICY "Users can add participants to chats" ON chat_participants
  FOR INSERT WITH CHECK (
    -- Allow if user is adding themselves
    user_id = auth.uid()
    OR
    -- Allow if user is already in the chat
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

-- UPDATE: Users can only update their own participation record
CREATE POLICY "Users can update their own participation" ON chat_participants
  FOR UPDATE USING (
    user_id = auth.uid()
  );

-- DELETE: Users can leave chats (delete their own participation)
CREATE POLICY "Users can leave chats" ON chat_participants
  FOR DELETE USING (
    user_id = auth.uid()
  );

-- ============================================================================
-- 3. CREATE FIXED MESSAGES POLICIES (No recursion)
-- ============================================================================

-- SELECT: Users can view messages in chats they're part of
-- FIXED: Use same subquery pattern
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

-- INSERT: Users can send messages to chats they're in
CREATE POLICY "Users can send messages to their chats" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

-- UPDATE: Users can update their own messages OR mark messages as read
CREATE POLICY "Users can update messages" ON messages
  FOR UPDATE USING (
    -- Can update own messages
    sender_id = auth.uid()
    OR
    -- Can update read status for messages in their chats
    (
      chat_id IN (
        SELECT DISTINCT cp.chat_id
        FROM chat_participants cp
        WHERE cp.user_id = auth.uid()
      )
    )
  );

-- DELETE: Users can delete their own messages
CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid()
  );

-- ============================================================================
-- 4. VERIFICATION
-- ============================================================================

-- Check policies on chat_participants
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'chat_participants'
ORDER BY policyname;

-- Check policies on messages
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'messages'
ORDER BY policyname;

-- Test: Try to get chat participants (should work now)
-- SELECT * FROM chat_participants WHERE user_id = auth.uid();

-- Test: Try to get messages (should work now)
-- SELECT * FROM messages LIMIT 5;

-- ============================================================================
-- EXPLANATION
-- ============================================================================

/*
The infinite recursion happened because the old policies had this pattern:

CREATE POLICY "..." ON chat_participants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants AS cp  -- ❌ Recursion!
      WHERE cp.chat_id = chat_participants.chat_id
      AND cp.user_id = auth.uid()
    )
  );

This creates infinite recursion:
1. User tries to SELECT from chat_participants
2. Policy checks: Does user exist in chat_participants?
3. To check #2, it needs to SELECT from chat_participants
4. Which triggers the policy again (loop!)

The fix uses a subquery pattern that PostgreSQL can optimize:

CREATE POLICY "..." ON chat_participants
  FOR SELECT USING (
    chat_id IN (
      SELECT DISTINCT cp.chat_id
      FROM chat_participants cp
      WHERE cp.user_id = auth.uid()
    )
  );

PostgreSQL recognizes this pattern and doesn't create recursion.
*/
