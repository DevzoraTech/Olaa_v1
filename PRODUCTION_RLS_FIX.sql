-- ============================================================================
-- PRODUCTION-READY RLS FIX
-- ============================================================================
-- This is a secure, production-ready fix for the infinite recursion issue
-- ============================================================================

-- Step 1: Create a secure function to get user's chat IDs
-- This function uses SECURITY DEFINER to avoid RLS recursion
CREATE OR REPLACE FUNCTION get_user_chat_ids()
RETURNS SETOF UUID AS $$
BEGIN
    -- This function runs with elevated privileges to avoid RLS recursion
    RETURN QUERY
    SELECT DISTINCT cp.chat_id
    FROM chat_participants cp
    WHERE cp.user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_chat_ids() TO authenticated;

-- Step 3: Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;

DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to their chats" ON messages;
DROP POLICY IF EXISTS "Users can update messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- Step 4: Create production-ready policies using the secure function
-- CHAT_PARTICIPANTS POLICIES
CREATE POLICY "chat_participants_select_policy" ON chat_participants
    FOR SELECT 
    USING (chat_id = ANY(SELECT get_user_chat_ids()));

CREATE POLICY "chat_participants_insert_policy" ON chat_participants
    FOR INSERT 
    WITH CHECK (
        -- Users can add themselves to chats
        user_id = auth.uid()
        OR
        -- Users can add others to chats they're already in
        chat_id = ANY(SELECT get_user_chat_ids())
    );

CREATE POLICY "chat_participants_update_policy" ON chat_participants
    FOR UPDATE 
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "chat_participants_delete_policy" ON chat_participants
    FOR DELETE 
    USING (user_id = auth.uid());

-- MESSAGES POLICIES
CREATE POLICY "messages_select_policy" ON messages
    FOR SELECT 
    USING (chat_id = ANY(SELECT get_user_chat_ids()));

CREATE POLICY "messages_insert_policy" ON messages
    FOR INSERT 
    WITH CHECK (
        sender_id = auth.uid() 
        AND chat_id = ANY(SELECT get_user_chat_ids())
    );

CREATE POLICY "messages_update_policy" ON messages
    FOR UPDATE 
    USING (
        sender_id = auth.uid() 
        OR chat_id = ANY(SELECT get_user_chat_ids())
    )
    WITH CHECK (
        sender_id = auth.uid() 
        OR chat_id = ANY(SELECT get_user_chat_ids())
    );

CREATE POLICY "messages_delete_policy" ON messages
    FOR DELETE 
    USING (sender_id = auth.uid());

-- Step 5: Ensure RLS is enabled (should already be enabled)
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Step 6: Verify the setup
SELECT 
    'Production RLS Policies Created Successfully!' as status,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename IN ('chat_participants', 'messages');

-- Step 7: Show created policies
SELECT 
    tablename,
    policyname,
    cmd,
    CASE 
        WHEN cmd = 'SELECT' THEN 'Read access'
        WHEN cmd = 'INSERT' THEN 'Create access'
        WHEN cmd = 'UPDATE' THEN 'Modify access'
        WHEN cmd = 'DELETE' THEN 'Delete access'
        ELSE cmd
    END as access_type
FROM pg_policies 
WHERE tablename IN ('chat_participants', 'messages')
ORDER BY tablename, cmd, policyname;
