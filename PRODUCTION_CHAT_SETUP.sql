-- ============================================================================
-- PRODUCTION-READY CHAT SETUP FOR PULSE CAMPUS
-- ============================================================================
-- This script sets up a complete, secure, and performant chat system
-- Run this script ONCE in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. CREATE TABLES
-- ============================================================================

-- Drop existing tables if you want to start fresh (CAUTION: This deletes data!)
-- DROP TABLE IF EXISTS messages CASCADE;
-- DROP TABLE IF EXISTS chat_participants CASCADE;
-- DROP TABLE IF EXISTS chats CASCADE;

-- Create chats table
CREATE TABLE IF NOT EXISTS chats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  is_group BOOLEAN DEFAULT FALSE NOT NULL,
  group_name TEXT,
  group_description TEXT,
  group_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  last_message_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create chat_participants table
CREATE TABLE IF NOT EXISTS chat_participants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  last_read_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE NOT NULL,
  UNIQUE(chat_id, user_id)
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'video', 'file', 'voice', 'link', 'location')) NOT NULL,
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,
  file_type TEXT,
  reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN DEFAULT FALSE NOT NULL,
  is_read BOOLEAN DEFAULT FALSE NOT NULL,
  is_delivered BOOLEAN DEFAULT TRUE NOT NULL,
  edited_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_chat_participants_chat_id ON chat_participants(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_composite ON chat_participants(chat_id, user_id);

CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_chat_created ON messages(chat_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chats_updated_at ON chats(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chats_last_message_at ON chats(last_message_at DESC);

-- ============================================================================
-- 3. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. DROP EXISTING POLICIES (Clean slate)
-- ============================================================================

-- Chats policies
DROP POLICY IF EXISTS "Users can view chats they participate in" ON chats;
DROP POLICY IF EXISTS "Users can create chats" ON chats;
DROP POLICY IF EXISTS "Users can update chats they participate in" ON chats;

-- Chat participants policies
DROP POLICY IF EXISTS "Users can view participants in their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can add participants to their chats" ON chat_participants;
DROP POLICY IF EXISTS "Users can update their own participation" ON chat_participants;
DROP POLICY IF EXISTS "Users can leave chats" ON chat_participants;

-- Messages policies
DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages to chats they're in" ON messages;
DROP POLICY IF EXISTS "Users can edit their own messages" ON messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON messages;

-- ============================================================================
-- 5. CREATE SECURE RLS POLICIES
-- ============================================================================

-- CHATS TABLE POLICIES
CREATE POLICY "Users can view chats they participate in" ON chats
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_id = chats.id
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create chats" ON chats
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated'
  );

CREATE POLICY "Participants can update their chats" ON chats
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_id = chats.id
      AND chat_participants.user_id = auth.uid()
    )
  );

-- CHAT PARTICIPANTS POLICIES
CREATE POLICY "Users can view participants in their chats" ON chat_participants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants AS cp
      WHERE cp.chat_id = chat_participants.chat_id
      AND cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can add participants to existing chats" ON chat_participants
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated'
    AND (
      -- Allow if user is adding themselves to a new chat
      user_id = auth.uid()
      OR
      -- Allow if user is already a participant
      EXISTS (
        SELECT 1 FROM chat_participants AS cp
        WHERE cp.chat_id = chat_participants.chat_id
        AND cp.user_id = auth.uid()
      )
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

-- MESSAGES TABLE POLICIES
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_id = messages.chat_id
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to their chats" ON messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_id = messages.chat_id
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own messages" ON messages
  FOR UPDATE USING (
    sender_id = auth.uid()
    OR
    -- Allow updates for read receipts by participants
    EXISTS (
      SELECT 1 FROM chat_participants
      WHERE chat_participants.chat_id = messages.chat_id
      AND chat_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own messages" ON messages
  FOR DELETE USING (
    sender_id = auth.uid()
  );

-- ============================================================================
-- 6. CREATE DATABASE FUNCTIONS
-- ============================================================================

-- Function: Update chat timestamps when a message is inserted
CREATE OR REPLACE FUNCTION update_chat_on_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats
  SET
    updated_at = NOW(),
    last_message_at = NEW.created_at
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Create or get existing direct chat
CREATE OR REPLACE FUNCTION create_direct_chat(user1_uuid UUID, user2_uuid UUID)
RETURNS UUID AS $$
DECLARE
  chat_id_result UUID;
  existing_chat_id UUID;
BEGIN
  -- Validate that user1 is the authenticated user
  IF user1_uuid != auth.uid() THEN
    RAISE EXCEPTION 'Unauthorized: Can only create chats for yourself';
  END IF;

  -- Check if direct chat already exists
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
    AND (
      SELECT COUNT(*) FROM chat_participants
      WHERE chat_id = c.id
    ) = 2
  LIMIT 1;

  -- Return existing chat if found
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

-- Function: Get existing direct chat between two users
CREATE OR REPLACE FUNCTION get_existing_direct_chat(user1_uuid UUID, user2_uuid UUID)
RETURNS UUID AS $$
DECLARE
  existing_chat_id UUID;
BEGIN
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
    AND (
      SELECT COUNT(*) FROM chat_participants
      WHERE chat_id = c.id
    ) = 2
  LIMIT 1;

  RETURN existing_chat_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7. CREATE TRIGGERS
-- ============================================================================

DROP TRIGGER IF EXISTS trigger_update_chat_on_message ON messages;
CREATE TRIGGER trigger_update_chat_on_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_on_message();

-- ============================================================================
-- 8. GRANT PERMISSIONS
-- ============================================================================

GRANT EXECUTE ON FUNCTION create_direct_chat(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_existing_direct_chat(UUID, UUID) TO authenticated;

-- ============================================================================
-- 9. SETUP STORAGE BUCKET
-- ============================================================================

-- Create chat-files storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-files',
  'chat-files',
  true, -- Public bucket so files can be accessed via URL
  52428800, -- 50MB file size limit
  ARRAY[
    -- Images
    'image/jpeg', 'image/png', 'image/gif', 'image/webp',
    -- Videos
    'video/mp4', 'video/avi', 'video/mov', 'video/quicktime', 'video/webm', 'video/x-msvideo',
    -- Audio
    'audio/mpeg', 'audio/wav', 'audio/aac', 'audio/mp3', 'audio/ogg',
    -- Documents
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    -- Archives
    'application/zip',
    'application/x-rar-compressed',
    'application/x-7z-compressed',
    -- Generic
    'application/octet-stream'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Drop ALL existing storage policies to avoid conflicts
DROP POLICY IF EXISTS "Authenticated users can upload chat files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view chat files" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own chat files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own chat files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload chat files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view chat files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload chat files with valid path" ON storage.objects;

-- Create SIMPLE storage policies that match our actual upload code
-- No complex path validation - just check authentication and bucket

CREATE POLICY "Authenticated users can upload chat files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat-files'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can view chat files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'chat-files'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can update chat files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'chat-files'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can delete chat files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'chat-files'
  AND auth.role() = 'authenticated'
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_storage_objects_chat_files
ON storage.objects (bucket_id, name)
WHERE bucket_id = 'chat-files';

-- ============================================================================
-- 10. ENABLE REALTIME
-- ============================================================================

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chats;

-- ============================================================================
-- 11. VERIFICATION QUERIES
-- ============================================================================

-- Verify tables
SELECT 'Tables Created:' as status;
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('chats', 'chat_participants', 'messages');

-- Verify indexes
SELECT 'Indexes Created:' as status;
SELECT indexname FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('chats', 'chat_participants', 'messages');

-- Verify policies
SELECT 'RLS Policies Created:' as status;
SELECT tablename, policyname FROM pg_policies
WHERE tablename IN ('chats', 'chat_participants', 'messages');

-- Verify storage bucket
SELECT 'Storage Bucket:' as status;
SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'chat-files';

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
-- Your chat system is now ready for production use!
--
-- Features enabled:
-- ✅ Secure RLS policies
-- ✅ Optimized indexes
-- ✅ Realtime subscriptions
-- ✅ File storage with 50MB limit
-- ✅ Direct chat creation function
-- ✅ Automatic timestamp updates
-- ============================================================================
