-- Fix Chat Schema Issues - Complete Migration
-- This script addresses all the schema cache errors

-- 1. Add missing columns to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Create indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_profiles_is_online ON profiles(is_online);
CREATE INDEX IF NOT EXISTS idx_profiles_last_seen ON profiles(last_seen);

-- 3. Update existing profiles to have default values
UPDATE profiles SET 
  is_online = FALSE,
  last_seen = NOW()
WHERE is_online IS NULL OR last_seen IS NULL;

-- 4. Ensure foreign key relationships exist
-- Check if foreign keys exist, if not create them
DO $$
BEGIN
  -- Foreign key from chat_participants to profiles
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'chat_participants_user_id_fkey'
  ) THEN
    ALTER TABLE chat_participants 
    ADD CONSTRAINT chat_participants_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;

  -- Foreign key from messages to profiles (sender_id)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'messages_sender_id_fkey'
  ) THEN
    ALTER TABLE messages 
    ADD CONSTRAINT messages_sender_id_fkey 
    FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;

  -- Foreign key from chats to profiles (last_message_sender_id)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'chats_last_message_sender_id_fkey'
  ) THEN
    ALTER TABLE chats 
    ADD CONSTRAINT chats_last_message_sender_id_fkey 
    FOREIGN KEY (last_message_sender_id) REFERENCES auth.users(id) ON DELETE SET NULL;
  END IF;
END $$;

-- 5. Update RLS policies to work with the new schema
-- Drop existing policies that might be causing issues
DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to chats they're in" ON messages;
DROP POLICY IF EXISTS "Users can edit their own messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- Recreate message policies with proper relationships
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants 
      WHERE chat_participants.chat_id = messages.chat_id 
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to chats they're in" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM chat_participants 
      WHERE chat_participants.chat_id = messages.chat_id 
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can edit their own messages" ON messages
  FOR UPDATE USING (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM chat_participants 
      WHERE chat_participants.chat_id = messages.chat_id 
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM chat_participants 
      WHERE chat_participants.chat_id = messages.chat_id 
      AND chat_participants.user_id = auth.uid()
    )
  );

-- 6. Update getUserChats function to work without joins
CREATE OR REPLACE FUNCTION get_user_chats(user_uuid UUID)
RETURNS TABLE (
  id UUID,
  is_group BOOLEAN,
  group_name TEXT,
  group_description TEXT,
  group_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  last_message_at TIMESTAMP WITH TIME ZONE,
  last_message TEXT,
  last_message_sender_id UUID,
  unread_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.is_group,
    c.group_name,
    c.group_description,
    c.group_image_url,
    c.created_at,
    c.updated_at,
    c.last_message_at,
    c.last_message,
    c.last_message_sender_id,
    COALESCE(c.unread_count, 0)::INTEGER
  FROM chats c
  INNER JOIN chat_participants cp ON c.id = cp.chat_id
  WHERE cp.user_id = user_uuid
  ORDER BY c.last_message_at DESC NULLS LAST, c.updated_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Update getChatParticipants function to work without joins
CREATE OR REPLACE FUNCTION get_chat_participants_with_profiles(chat_uuid UUID)
RETURNS TABLE (
  id UUID,
  chat_id UUID,
  user_id UUID,
  joined_at TIMESTAMP WITH TIME ZONE,
  last_read_at TIMESTAMP WITH TIME ZONE,
  is_admin BOOLEAN,
  profile JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cp.id,
    cp.chat_id,
    cp.user_id,
    cp.joined_at,
    cp.last_read_at,
    cp.is_admin,
    jsonb_build_object(
      'id', p.id,
      'first_name', p.first_name,
      'last_name', p.last_name,
      'email', p.email,
      'phone_number', p.phone_number,
      'profile_image_url', p.profile_image_url,
      'is_online', p.is_online,
      'last_seen', p.last_seen,
      'primary_role', p.primary_role,
      'campus', p.campus,
      'course', p.course,
      'year_of_study', p.year_of_study
    ) as profile
  FROM chat_participants cp
  INNER JOIN profiles p ON cp.user_id = p.id
  WHERE cp.chat_id = chat_uuid
  ORDER BY cp.joined_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_chats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_chat_participants_with_profiles(UUID) TO authenticated;

-- 9. Update the database service methods to use these functions
-- (This will be handled in the Dart code)

-- 10. Verify the schema
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name IN ('profiles', 'chats', 'chat_participants', 'messages')
  AND column_name IN ('is_online', 'last_seen', 'last_message_sender_id')
ORDER BY table_name, column_name;

-- 11. Test the functions
-- SELECT * FROM get_user_chats('your-user-id-here');
-- SELECT * FROM get_chat_participants_with_profiles('your-chat-id-here');
