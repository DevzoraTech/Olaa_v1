-- ============================================================================
-- EMERGENCY FIX: Complete RLS Reset
-- ============================================================================
-- This will completely disable and recreate RLS policies to fix infinite recursion
-- ============================================================================

-- Step 1: Completely disable RLS on both tables
ALTER TABLE chat_participants DISABLE ROW LEVEL SECURITY;
ALTER TABLE messages DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL policies (this will work even if they don't exist)
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    -- Drop all policies on chat_participants
    FOR policy_record IN 
        SELECT policyname FROM pg_policies WHERE tablename = 'chat_participants'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON chat_participants';
    END LOOP;
    
    -- Drop all policies on messages
    FOR policy_record IN 
        SELECT policyname FROM pg_policies WHERE tablename = 'messages'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON messages';
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Step 4: Create simple, non-recursive policies using functions
-- First create helper functions to avoid recursion

-- Function to get user's chat IDs
CREATE OR REPLACE FUNCTION get_user_chat_ids(user_uuid UUID)
RETURNS TABLE(chat_id UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT cp.chat_id
    FROM chat_participants cp
    WHERE cp.user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create policies using the helper function
CREATE POLICY "chat_participants_select" ON chat_participants
    FOR SELECT USING (chat_id = ANY(SELECT get_user_chat_ids(auth.uid())));

CREATE POLICY "chat_participants_insert" ON chat_participants
    FOR INSERT WITH CHECK (
        user_id = auth.uid() OR 
        chat_id = ANY(SELECT get_user_chat_ids(auth.uid()))
    );

CREATE POLICY "chat_participants_update" ON chat_participants
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "chat_participants_delete" ON chat_participants
    FOR DELETE USING (user_id = auth.uid());

CREATE POLICY "messages_select" ON messages
    FOR SELECT USING (chat_id = ANY(SELECT get_user_chat_ids(auth.uid())));

CREATE POLICY "messages_insert" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND 
        chat_id = ANY(SELECT get_user_chat_ids(auth.uid()))
    );

CREATE POLICY "messages_update" ON messages
    FOR UPDATE USING (
        sender_id = auth.uid() OR 
        chat_id = ANY(SELECT get_user_chat_ids(auth.uid()))
    );

CREATE POLICY "messages_delete" ON messages
    FOR DELETE USING (sender_id = auth.uid());

-- Step 6: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON chat_participants TO authenticated;
GRANT ALL ON messages TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_chat_ids(UUID) TO authenticated;

-- Step 7: Verify the fix
SELECT 'RLS Policies Fixed Successfully!' as status;
SELECT tablename, policyname, cmd FROM pg_policies 
WHERE tablename IN ('chat_participants', 'messages')
ORDER BY tablename, policyname;